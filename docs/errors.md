# Errors

How to navigate and resolve problems. When told to reference this file, follow the full triage process before attempting any fix.

---

## Error Handling Philosophy

- Never silently swallow errors — always surface to user or log
- Supabase errors get logged before throwing
- Show user-friendly messages, log technical details separately
- Fix the root cause, not the symptom
- Do not refactor surrounding code while fixing a bug
- Do not update `tasks.md` until the fix is confirmed working

---

## Triage Process

When an error is reported, assume the reporter has missed information. Do not assume you have the full picture. Work through every step in order.

### Step 1 — Clarify Before Touching Anything

Ask every question needed to fully understand the problem. Do not assume. Do not guess.

Ask:
- What exactly is the error message or behavior? (exact text, screenshot if possible)
- What were you doing when it happened? (which screen, which action)
- Does it happen every time or only sometimes?
- Did it ever work before? If yes, what changed?
- Which platform / device is this on?
- Is there anything in the Flutter console or Supabase logs?

Do not proceed to Step 2 until you can state the problem precisely in one sentence.

### Step 2 — Map the Problem Using Docs

Read the following in order before touching any code:

1. `docs/architecture.md` — identify which feature area is involved and locate the relevant spec
2. `specs/[feature]_spec.md` → Code Map section — find the exact file and function responsible
3. `docs/data_structure.md` — if the error involves data, check schema and RLS policies
4. `docs/errors.md` — check prior error log entries for related issues and past resolutions
5. Read the actual code at the location identified by the spec Code Map — confirm root cause before proposing any fix

State your diagnosis clearly before writing a single line of code.

### Step 3 — Attempt Fix

Fix only what is broken. Do not touch surrounding code. Do not refactor. Do not "improve" while you're in there.

After the fix: confirm it works. If confirmed, update `docs/tasks.md` and log resolution in the error entry below.

### Step 4 — If Step 3 Fails: Add Logging

If the fix did not work:
- Add `debugPrint()` statements at key points in the relevant Dart code
- Check Flutter debug console output
- Check Supabase dashboard logs (Auth logs, Edge Function logs, Database logs)
- Check Supabase RLS policies — silent insert/update failures are almost always RLS
- Report what the logs reveal before attempting another fix

### Step 5 — If Step 4 Still Fails: Update Docs and Escalate

If after two fix attempts the problem is unresolved:
- Log full details in the error entry below
- If the issue reveals a gap in a spec or a rule that needs adding, update the relevant doc
- Stop and escalate to Claude (if this is Codex) or to the director (if this is Claude)

---

## Error Type Routing

| Error Type                       | First Stop                              | Second Stop             |
|----------------------------------|-----------------------------------------|-------------------------|
| Math / calculation wrong         | `helpers/[feature]_calculations.dart`   | spec Code Map           |
| Validation not working           | `helpers/[feature]_validators.dart`     | spec validation rules   |
| UI displaying wrong data         | relevant `_provider.dart`               | spec page state         |
| Supabase insert/update failing   | RLS policies first                      | `supabase_service.dart` |
| Auth error                       | `auth_service.dart`                     | Supabase Auth logs      |
| Edge function error              | Supabase Edge Function logs             | edge function code      |
| State not updating               | relevant `_provider.dart`               | spec page state         |
| Layout broken on specific device | relevant layout file                    | spec layouts section    |

---

## What Not To Do During Error Resolution

- Do not change data models to fix a UI bug
- Do not modify schema to fix an app-layer problem
- Do not update `tasks.md` until fix is confirmed working
- Do not touch layout files to fix logic bugs (fix helpers instead)
- Do not attempt a third fix without escalating first

---

## Error Log

### Entry Format

```
### ERR-000 · [short description]
- **Date:**
- **Status:** Blocked / Resolved
- **Feature area:**
- **What was reported:**
- **Clarifying questions asked / answers received:**
- **Root cause:**
- **What was tried:**
- **Resolution:**
- **Docs updated as result:**
```

---

### ERR-001 · org_members RLS recursion on live API access
- **Date:** 2026-03-15
- **Status:** Resolved
- **Feature area:** Supabase schema / RLS (TASK-001)
- **What was reported:** Profile and membership reads returned `42P17` with message `infinite recursion detected in policy for relation "org_members"`.
- **Clarifying questions asked / answers received:** Verified against live signup + authenticated REST queries; recursion reproduced consistently.
- **Root cause:** `org_members` policies referenced `org_members` in policy predicates, recursively re-triggering RLS evaluation.
- **What was tried:** Added `security definer` helper functions (`is_org_member`, `is_org_admin`) and rewrote `org_members` policies to call those helpers instead of self-querying in policy SQL.
- **Resolution:** Applied migration `supabase/migrations/20260316034647_task001_fix_org_members_rls_recursion.sql`, then verified successful signup/profile lookup and table access checks.
- **Docs updated as result:** None (implementation-level migration fix only).

### ERR-002 · TASK-004 cannot start (missing spec)
- **Date:** 2026-03-15
- **Status:** Resolved
- **Feature area:** Task execution workflow
- **What was reported:** TASK-004 depends on `specs/orgs_spec.md`, but that file does not exist in the repo.
- **Clarifying questions asked / answers received:** None needed; file presence verified locally.
- **Root cause:** Required spec file has not been authored yet.
- **What was tried:** Checked `specs/` directory and task instructions; no fallback spec available.
- **Resolution:** `specs/orgs_spec.md` was authored; TASK-004 completed successfully.
- **Docs updated as result:** `docs/tasks.md` TASK-004 marked done.

### ERR-003 · TASK-005 cannot start (missing spec)
- **Date:** 2026-03-16
- **Status:** Resolved
- **Feature area:** Task execution workflow
- **What was reported:** TASK-005 is marked `ready`, but required file `specs/shell_spec.md` does not exist.
- **Clarifying questions asked / answers received:** Verified file presence directly in `specs/`; only `_spec_template.md`, `auth_spec.md`, and `orgs_spec.md` exist.
- **Root cause:** Required shell spec has not been authored yet.
- **What was tried:** Confirmed task metadata and local filesystem state.
- **Resolution:** `specs/shell_spec.md` was added; TASK-005 started and implemented.
- **Docs updated as result:** `docs/tasks.md` status moved from blocked to in-progress, then to ready-to-review after implementation.

### ERR-004 · TASK-007 cannot start (missing spec)
- **Date:** 2026-03-16
- **Status:** Resolved
- **Feature area:** Task execution workflow
- **What was reported:** TASK-007 depends on `specs/settings_spec.md`, but the file is not present.
- **Clarifying questions asked / answers received:** Verified local `specs/` contents; `settings_spec.md` is missing.
- **Root cause:** Required settings spec has not been authored yet.
- **What was tried:** Confirmed task metadata and filesystem state.
- **Resolution:** `specs/settings_spec.md` was added, TASK-007 was implemented, and status moved to `ready-to-review`.
- **Docs updated as result:** `docs/tasks.md` updated from blocked → in-progress → ready-to-review for TASK-007.

### ERR-005 · TASK-008 cannot start (missing spec)
- **Date:** 2026-03-16
- **Status:** Resolved
- **Feature area:** Task execution workflow
- **What was reported:** TASK-008 requires `specs/transactions_spec.md`, but the file is not present.
- **Clarifying questions asked / answers received:** Verified local `specs/` contents; `transactions_spec.md` is missing.
- **Root cause:** Required transactions spec has not been authored yet.
- **What was tried:** Confirmed task metadata and filesystem state.
- **Resolution:** `specs/transactions_spec.md` was added, TASK-008 was implemented, and status moved to `ready-to-review`.
- **Docs updated as result:** `docs/tasks.md` TASK-008 status moved blocked → in-progress → ready-to-review.

### ERR-006 · TASK-015 cannot start (missing spec)
- **Date:** 2026-03-16
- **Status:** Resolved
- **Feature area:** Task execution workflow
- **What was reported:** Task kickoff request for TASK-015 was received, but required file `specs/receipts_spec.md` is not present.
- **Clarifying questions asked / answers received:** Verified local `specs/` directory contents; no receipts spec file exists yet.
- **Root cause:** Required receipts spec has not been authored.
- **What was tried:** Read `CODEX.md`, `docs/architecture.md`, and `docs/tasks.md`; confirmed TASK-015 still references `specs/receipts_spec.md`.
- **Resolution:** `specs/receipts_spec.md` was added; TASK-015 started and moved to `ready-to-review` after implementation and validation.
- **Docs updated as result:** `docs/tasks.md` moved TASK-015 from `blocked` → `in-progress` → `ready-to-review`.

### ERR-007 · Global analyzer blocked by unrelated in-progress features during TASK-012
- **Date:** 2026-03-16
- **Status:** Resolved
- **Feature area:** Validation / analyzer workflow
- **What was reported:** `flutter analyze` and `flutter run -d chrome` fail after TASK-012 changes, but reported errors are in monthly/receipts files outside dashboard scope.
- **Clarifying questions asked / answers received:** None needed; analyzer output reviewed and file paths confirmed.
- **Root cause:** Pre-existing implementation issues in `lib/features/monthly/...` and `lib/features/receipts/...` (tasks in progress) are currently preventing full-project analyzer clean.
- **What was tried:** Ran full `flutter analyze`, attempted `flutter run -d chrome` (compile fails in `monthly_budget_view.dart`), then narrowed validation to `flutter analyze lib/features/dashboard lib/core/routing/app_router.dart`.
- **Resolution:** Dashboard and routing changes for TASK-012 analyze clean; full app compile remains blocked by unrelated files and was not modified in this task.
- **Docs updated as result:** `docs/errors.md` logged validation constraint for review context.
