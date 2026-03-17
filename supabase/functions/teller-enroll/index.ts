import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type EnrollRequest = {
  enrollmentId: string;
  accessToken: string;
  orgId: string;
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  try {
    const admin = createAdminClient();
    const userId = await authenticateUser(req, admin);
    const payload = await parseBody(req);

    await assertOrgMembership(admin, payload.orgId, userId);

    const accounts = await fetchTellerAccounts(payload.accessToken);
    if (accounts.length === 0) {
      throw new Error('Teller did not return any accounts for this enrollment.');
    }

    const primaryAccount = accounts[0];
    const institutionName =
      readNestedString(primaryAccount, ['institution', 'name'])
      ?? readNestedString(primaryAccount, ['institution', 'display_name'])
      ?? readString(primaryAccount, 'institution_name')
      ?? 'Connected Institution';

    const accountName =
      readString(primaryAccount, 'name')
      ?? readString(primaryAccount, 'nickname')
      ?? 'Connected Account';

    const accountLastFour =
      readString(primaryAccount, 'last_four')
      ?? readString(primaryAccount, 'lastFour');

    const accountType = readString(primaryAccount, 'type') ?? 'depository';
    const accountSubtype = readString(primaryAccount, 'subtype');

    const { data, error } = await admin
      .from('teller_enrollments')
      .insert({
        org_id: payload.orgId,
        profile_id: userId,
        teller_enrollment_id: payload.enrollmentId,
        teller_access_token: payload.accessToken,
        institution_name: institutionName,
        account_name: accountName,
        account_last_four: accountLastFour,
        account_type: accountType,
        account_subtype: accountSubtype,
        is_active: true,
      })
      .select('id')
      .single();

    if (error || !data?.id) {
      throw new Error(`Unable to save Teller enrollment: ${error?.message ?? 'unknown error'}`);
    }

    // Initial sync is best-effort — don't fail enrollment if sync call fails
    triggerInitialSync(payload.orgId, data.id).catch((err) => {
      console.error('Initial sync failed (non-fatal):', err?.message ?? err);
    });

    return jsonResponse({ success: true, enrollmentId: data.id });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected error';
    const stack = error instanceof Error ? error.stack : '';
    console.error('teller-enroll error:', message, stack);
    const status = message.toLowerCase().includes('unauthorized') ? 401 : 500;
    return jsonResponse({ error: message }, status);
  }
});

async function triggerInitialSync(orgId: string, enrollmentId: string): Promise<void> {
  const functionUrl = `${requireEnv('SUPABASE_URL')}/functions/v1/teller-sync`;
  const serviceRoleKey = requireEnv('SUPABASE_SERVICE_ROLE_KEY');

  const response = await fetch(functionUrl, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      orgId,
      enrollmentId,
      initialSync: true,
    }),
  });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Unable to start initial Teller sync: ${details}`);
  }
}

async function fetchTellerAccounts(accessToken: string): Promise<Record<string, unknown>[]> {
  const client = createTellerHttpClient();
  const response = await fetch(`${tellerBaseUrl()}/accounts`, {
    method: 'GET',
    headers: {
      Authorization: `Basic ${btoa(`${accessToken}:`)}`,
    },
    client,
  } as RequestInit & { client: Deno.HttpClient });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Teller /accounts failed (${response.status}): ${details}`);
  }

  const payload = await response.json().catch(() => null);
  if (!Array.isArray(payload)) {
    return [];
  }

  return payload.filter((value): value is Record<string, unknown> => {
    return value !== null && typeof value === 'object';
  });
}

function createTellerHttpClient(): Deno.HttpClient {
  const cert = decodeMaybeBase64(requireEnv('TELLER_CERT'));
  const key = decodeMaybeBase64(requireEnv('TELLER_KEY'));
  // Deno v2 uses 'cert'/'key' instead of 'certChain'/'privateKey'
  return Deno.createHttpClient({ cert, key } as Deno.CreateHttpClientOptions);
}

function decodeMaybeBase64(value: string): string {
  const trimmed = value.trim();
  if (trimmed.includes('BEGIN')) {
    return trimmed;
  }

  try {
    const decoded = atob(trimmed);
    if (decoded.includes('BEGIN')) {
      return decoded;
    }
  } catch (_) {
    // Keep raw value if not base64.
  }

  return trimmed;
}

function tellerBaseUrl(): string {
  const env = (Deno.env.get('TELLER_ENV') ?? 'development').toLowerCase();
  if (env === 'sandbox') {
    return 'https://api-sandbox.teller.io';
  }
  return 'https://api.teller.io';
}

async function parseBody(req: Request): Promise<EnrollRequest> {
  const body = await req.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    throw new Error('Invalid request body.');
  }

  const payload = body as Record<string, unknown>;
  const enrollmentId = readString(payload, 'enrollmentId');
  const accessToken = readString(payload, 'accessToken');
  const orgId = readString(payload, 'orgId');

  if (!enrollmentId || !accessToken || !orgId) {
    throw new Error('enrollmentId, accessToken, and orgId are required.');
  }

  return { enrollmentId, accessToken, orgId };
}

function readNestedString(source: Record<string, unknown>, path: string[]): string | null {
  let current: unknown = source;
  for (const segment of path) {
    if (!current || typeof current !== 'object') {
      return null;
    }

    current = (current as Record<string, unknown>)[segment];
  }

  if (current === null || current === undefined) {
    return null;
  }

  const value = String(current).trim();
  return value ? value : null;
}

function readString(source: Record<string, unknown>, key: string): string | null {
  const value = source[key];
  if (value === null || value === undefined) {
    return null;
  }

  const normalized = String(value).trim();
  return normalized ? normalized : null;
}

async function authenticateUser(
  req: Request,
  admin: ReturnType<typeof createAdminClient>,
): Promise<string> {
  const token = readBearerToken(req);
  const { data, error } = await admin.auth.getUser(token);

  if (error || !data.user) {
    throw new Error('Unauthorized: invalid JWT.');
  }

  return data.user.id;
}

async function assertOrgMembership(
  admin: ReturnType<typeof createAdminClient>,
  orgId: string,
  userId: string,
): Promise<void> {
  const { data, error } = await admin
    .from('org_members')
    .select('id')
    .eq('org_id', orgId)
    .eq('profile_id', userId)
    .maybeSingle();

  if (error || !data) {
    throw new Error('Unauthorized: not a member of this organization.');
  }
}

function readBearerToken(req: Request): string {
  const authorization = req.headers.get('Authorization') ?? req.headers.get('authorization');
  if (!authorization?.startsWith('Bearer ')) {
    throw new Error('Unauthorized: missing bearer token.');
  }

  const token = authorization.slice('Bearer '.length).trim();
  if (!token) {
    throw new Error('Unauthorized: empty bearer token.');
  }

  return token;
}

function createAdminClient() {
  return createClient(requireEnv('SUPABASE_URL'), requireEnv('SUPABASE_SERVICE_ROLE_KEY'));
}

function requireEnv(key: string): string {
  const value = Deno.env.get(key);
  if (!value || !value.trim()) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
