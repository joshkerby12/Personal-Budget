import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type AuthContext =
  | { kind: 'service' }
  | { kind: 'user'; userId: string };

type SyncRequest = {
  orgId?: string;
  enrollmentId?: string;
  initialSync?: boolean;
};

type TellerEnrollmentRow = {
  id: string;
  org_id: string;
  profile_id: string;
  teller_enrollment_id: string;
  teller_access_token: string;
  institution_name: string;
  account_name: string;
  account_last_four: string | null;
  account_type: string;
  account_subtype: string | null;
  last_synced_at: string | null;
  is_active: boolean;
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
    const auth = await authenticate(req, admin);
    const body = await parseBody(req);

    if (auth.kind === 'user') {
      if (!body.orgId) {
        return jsonResponse({ error: 'orgId is required for user-triggered sync.' }, 400);
      }

      await assertOrgMembership(admin, body.orgId, auth.userId);
    }

    const imported = await syncEnrollments(admin, auth, body);
    return jsonResponse({ imported });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected error';
    const status = message.toLowerCase().includes('unauthorized') ? 401 : 500;
    return jsonResponse({ error: message }, status);
  }
});

async function syncEnrollments(
  admin: ReturnType<typeof createAdminClient>,
  auth: AuthContext,
  payload: SyncRequest,
): Promise<number> {
  let query = admin
    .from('teller_enrollments')
    .select(
      'id, org_id, profile_id, teller_enrollment_id, teller_access_token, '
        + 'institution_name, account_name, account_last_four, account_type, '
        + 'account_subtype, last_synced_at, is_active',
    )
    .eq('is_active', true);

  if (payload.orgId) {
    query = query.eq('org_id', payload.orgId);
  }

  if (payload.enrollmentId) {
    query = query.eq('id', payload.enrollmentId);
  }

  const { data, error } = await query;
  if (error) {
    throw new Error(`Unable to load Teller enrollments: ${error.message}`);
  }

  const enrollments = (data ?? []) as TellerEnrollmentRow[];
  if (enrollments.length === 0) {
    return 0;
  }

  if (auth.kind === 'user' && payload.orgId) {
    const mismatched = enrollments.some((row) => row.org_id !== payload.orgId);
    if (mismatched) {
      throw new Error('Unauthorized enrollment scope.');
    }
  }

  let totalImported = 0;

  for (const enrollment of enrollments) {
    try {
      const imported = await syncSingleEnrollment(admin, enrollment, payload.initialSync === true);
      totalImported += imported;

      await admin.from('teller_sync_log').insert({
        enrollment_id: enrollment.id,
        transactions_imported: imported,
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Sync failed';
      console.error('syncSingleEnrollment error for enrollment', enrollment.id, ':', message);
      await admin.from('teller_sync_log').insert({
        enrollment_id: enrollment.id,
        transactions_imported: 0,
        error: message,
      });
    }
  }

  return totalImported;
}

async function syncSingleEnrollment(
  admin: ReturnType<typeof createAdminClient>,
  enrollment: TellerEnrollmentRow,
  initialSync: boolean,
): Promise<number> {
  const accounts = await fetchTellerAccounts(enrollment.teller_access_token);
  if (accounts.length === 0) {
    await markLastSynced(admin, enrollment.id);
    return 0;
  }

  const fromDate = computeFromDate(enrollment.last_synced_at, initialSync);
  let imported = 0;

  for (const account of accounts) {
    const accountId = stringOrNull(account?.id);
    if (!accountId) {
      continue;
    }

    const transactions = await fetchTellerTransactions(
      enrollment.teller_access_token,
      accountId,
      fromDate,
    );

    for (const tellerTransaction of transactions) {
      const row = mapTransactionRow(enrollment, account, tellerTransaction);
      if (!row) {
        continue;
      }

      const wasInserted = await insertTransaction(admin, row);
      if (wasInserted) {
        imported += 1;
      }
    }
  }

  await markLastSynced(admin, enrollment.id);
  return imported;
}

async function insertTransaction(
  admin: ReturnType<typeof createAdminClient>,
  row: Record<string, unknown>,
): Promise<boolean> {
  const { error } = await admin.from('transactions').insert(row);

  if (!error) {
    return true;
  }

  if ((error as { code?: string }).code === '23505') {
    return false;
  }

  throw new Error(`Failed to insert transaction: ${error.message}`);
}

async function markLastSynced(
  admin: ReturnType<typeof createAdminClient>,
  enrollmentId: string,
): Promise<void> {
  const { error } = await admin
    .from('teller_enrollments')
    .update({ last_synced_at: new Date().toISOString() })
    .eq('id', enrollmentId);

  if (error) {
    throw new Error(`Unable to update sync timestamp: ${error.message}`);
  }
}

function mapTransactionRow(
  enrollment: TellerEnrollmentRow,
  account: Record<string, unknown>,
  tellerTransaction: Record<string, unknown>,
): Record<string, unknown> | null {
  const tellerTransactionId = stringOrNull(tellerTransaction.id);
  const date = normalizeDate(tellerTransaction.date);
  const amountRaw = Number(tellerTransaction.amount ?? 0);
  const amount = Number.isFinite(amountRaw) ? Math.abs(amountRaw) : NaN;

  if (!tellerTransactionId || !date || !Number.isFinite(amount) || amount <= 0) {
    return null;
  }

  const description =
    normalizeText(stringOrNull(tellerTransaction.description), 200)
      ?? normalizeText(stringOrNull(tellerTransaction.name), 200)
      ?? 'Imported transaction';

  const transactionType = stringOrNull(tellerTransaction.type)?.toLowerCase();
  const accountType =
    stringOrNull(account.type)?.toLowerCase()
      ?? enrollment.account_type.toLowerCase();
  const isIncome = transactionType === 'credit' && accountType === 'depository';

  return {
    org_id: enrollment.org_id,
    created_by: enrollment.profile_id,
    date,
    amount,
    merchant: description,
    description,
    category: isIncome ? 'Income' : 'Uncategorized',
    subcategory: isIncome ? 'Other Income' : 'Uncategorized',
    biz_pct: 0,
    is_split: false,
    source: 'teller',
    teller_transaction_id: tellerTransactionId,
  };
}

async function fetchTellerAccounts(accessToken: string): Promise<Record<string, unknown>[]> {
  const response = await tellerFetch('/accounts', accessToken);
  const payload = await parseJsonResponse(response);

  if (!Array.isArray(payload)) {
    return [];
  }

  return payload.filter((value): value is Record<string, unknown> => {
    return value !== null && typeof value === 'object';
  });
}

async function fetchTellerTransactions(
  accessToken: string,
  accountId: string,
  fromDate: string,
): Promise<Record<string, unknown>[]> {
  const encodedAccountId = encodeURIComponent(accountId);
  const path = `/accounts/${encodedAccountId}/transactions?from_date=${encodeURIComponent(fromDate)}`;
  const response = await tellerFetch(path, accessToken);
  const payload = await parseJsonResponse(response);

  if (!Array.isArray(payload)) {
    return [];
  }

  return payload.filter((value): value is Record<string, unknown> => {
    return value !== null && typeof value === 'object';
  });
}

async function tellerFetch(path: string, accessToken: string): Promise<Response> {
  const client = createTellerHttpClient();
  const response = await fetch(`${tellerBaseUrl()}${path}`, {
    method: 'GET',
    headers: {
      Authorization: `Basic ${btoa(`${accessToken}:`)}`,
    },
    client,
  } as RequestInit & { client: Deno.HttpClient });

  if (!response.ok) {
    const details = await response.text();
    throw new Error(`Teller request failed (${response.status}): ${details}`);
  }

  return response;
}

function createTellerHttpClient(): Deno.HttpClient {
  const cert = decodeMaybeBase64(requireEnv('TELLER_CERT'));
  const key = decodeMaybeBase64(requireEnv('TELLER_KEY'));
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

function computeFromDate(lastSyncedAt: string | null, initialSync: boolean): string {
  if (initialSync || !lastSyncedAt) {
    const initial = new Date();
    initial.setUTCDate(initial.getUTCDate() - 90);
    return toDateString(initial);
  }

  const overlap = new Date(lastSyncedAt);
  if (Number.isNaN(overlap.valueOf())) {
    const fallback = new Date();
    fallback.setUTCDate(fallback.getUTCDate() - 90);
    return toDateString(fallback);
  }

  overlap.setUTCDate(overlap.getUTCDate() - 1);
  return toDateString(overlap);
}

function toDateString(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function normalizeDate(value: unknown): string | null {
  const raw = stringOrNull(value);
  if (!raw) {
    return null;
  }

  if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
    return raw;
  }

  const parsed = new Date(raw);
  if (Number.isNaN(parsed.valueOf())) {
    return null;
  }

  return toDateString(parsed);
}

function normalizeText(value: string | null, maxLength: number): string | null {
  if (!value) {
    return null;
  }

  const normalized = value.trim().replace(/\s+/g, ' ');
  if (!normalized) {
    return null;
  }

  return normalized.length > maxLength ? normalized.slice(0, maxLength) : normalized;
}

function stringOrNull(value: unknown): string | null {
  if (value === null || value === undefined) {
    return null;
  }

  const normalized = String(value).trim();
  return normalized ? normalized : null;
}

async function parseJsonResponse(response: Response): Promise<unknown> {
  try {
    return await response.json();
  } catch (_) {
    return null;
  }
}

async function parseBody(req: Request): Promise<SyncRequest> {
  try {
    const body = await req.json();
    if (!body || typeof body !== 'object') {
      return {};
    }

    const payload = body as Record<string, unknown>;
    return {
      orgId: stringOrNull(payload.orgId) ?? undefined,
      enrollmentId: stringOrNull(payload.enrollmentId) ?? undefined,
      initialSync: payload.initialSync === true,
    };
  } catch (_) {
    return {};
  }
}

async function authenticate(
  req: Request,
  admin: ReturnType<typeof createAdminClient>,
): Promise<AuthContext> {
  const token = readBearerToken(req);
  const serviceRoleKey = requireEnv('SUPABASE_SERVICE_ROLE_KEY');

  if (token === serviceRoleKey) {
    return { kind: 'service' };
  }

  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) {
    throw new Error('Unauthorized: invalid JWT.');
  }

  return { kind: 'user', userId: data.user.id };
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
