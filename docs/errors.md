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

*(no errors logged yet)*

Entry format:
```
### ERR-001 · [short description]
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
