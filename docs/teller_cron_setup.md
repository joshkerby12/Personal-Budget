# Teller Cron Setup

Run this SQL in the Supabase SQL editor after deploying the `teller-sync` Edge Function.

```sql
-- Ensure required extensions are enabled.
create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Run teller-sync every 6 hours for all active enrollments.
select cron.schedule(
  'teller-sync-6h',
  '0 */6 * * *',
  $$
  select net.http_post(
    url := 'https://xzjfxqkdzeawfnhfusut.supabase.co/functions/v1/teller-sync',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.supabase_service_role_key', true)
    ),
    body := '{}'::jsonb
  );
  $$
);
```

If your project does not expose `app.settings.supabase_service_role_key`, replace the `Authorization` expression with your service role key bearer value in the SQL editor before running it.
