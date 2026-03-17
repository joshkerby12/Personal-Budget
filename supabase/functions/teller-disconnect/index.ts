import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type DisconnectRequest = {
  enrollmentId: string;
};

type EnrollmentRow = {
  id: string;
  org_id: string;
  teller_enrollment_id: string;
  teller_access_token: string;
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

    const enrollment = await fetchEnrollment(admin, payload.enrollmentId);
    await assertOrgMembership(admin, enrollment.org_id, userId);

    await revokeTellerEnrollment(enrollment);

    const { error: updateError } = await admin
      .from('teller_enrollments')
      .update({ is_active: false })
      .eq('id', payload.enrollmentId);

    if (updateError) {
      throw new Error(`Unable to disconnect enrollment: ${updateError.message}`);
    }

    return jsonResponse({ success: true });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected error';
    const status = message.toLowerCase().includes('unauthorized') ? 401 : 500;
    return jsonResponse({ error: message }, status);
  }
});

async function revokeTellerEnrollment(enrollment: EnrollmentRow): Promise<void> {
  const client = createTellerHttpClient();
  const encodedId = encodeURIComponent(enrollment.teller_enrollment_id);
  const response = await fetch(`${tellerBaseUrl()}/enrollments/${encodedId}`, {
    method: 'DELETE',
    headers: {
      Authorization: `Basic ${btoa(`${enrollment.teller_access_token}:`)}`,
    },
    client,
  } as RequestInit & { client: Deno.HttpClient });

  if (!response.ok && response.status !== 404) {
    const details = await response.text();
    throw new Error(`Teller disconnect failed (${response.status}): ${details}`);
  }
}

async function fetchEnrollment(
  admin: ReturnType<typeof createAdminClient>,
  enrollmentId: string,
): Promise<EnrollmentRow> {
  const { data, error } = await admin
    .from('teller_enrollments')
    .select('id, org_id, teller_enrollment_id, teller_access_token')
    .eq('id', enrollmentId)
    .single();

  if (error || !data) {
    throw new Error(`Enrollment not found: ${error?.message ?? 'missing row'}`);
  }

  return data as EnrollmentRow;
}

async function parseBody(req: Request): Promise<DisconnectRequest> {
  const body = await req.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    throw new Error('Invalid request body.');
  }

  const payload = body as Record<string, unknown>;
  const enrollmentId = readString(payload, 'enrollmentId');
  if (!enrollmentId) {
    throw new Error('enrollmentId is required.');
  }

  return { enrollmentId };
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

function createTellerHttpClient(): Deno.HttpClient {
  const cert = decodeMaybeBase64(requireEnv('TELLER_CERT'));
  const key = decodeMaybeBase64(requireEnv('TELLER_KEY'));
  return Deno.createHttpClient({ certChain: cert, privateKey: key });
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
