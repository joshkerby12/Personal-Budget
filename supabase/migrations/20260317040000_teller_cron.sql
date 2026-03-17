-- Periodic Teller sync via pg_cron + pg_net
-- NOTE: Run this manually in the Supabase SQL Editor.
-- Replace <SERVICE_ROLE_KEY> with the actual service_role key from
-- Dashboard > Project Settings > API before running.
-- Do NOT commit this file with the key filled in.

select cron.schedule(
  'teller-sync-every-6h',
  '0 */6 * * *',
  $$
  select net.http_post(
    url     := 'https://xzjfxqkdzeawfnhfusut.supabase.co/functions/v1/teller-sync',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer <SERVICE_ROLE_KEY>"}'::jsonb,
    body    := '{}'::jsonb
  ) as request_id;
  $$
);
