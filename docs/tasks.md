# Tasks

Active task queue. Claude authors and scopes all tasks. Codex picks up `ready` tasks and implements them.

---

## Status Key

| Status | Meaning |
|---|---|
| `ready` | Scoped by Claude, ready for Codex to pick up |
| `in-progress` | Codex is actively working on it |
| `needs-review` | Codex finished, waiting for Claude/director review |
| `review-escalation` | Codex flagged a decision that needs Claude or director |
| `done` | Confirmed working |
| `blocked` | Codex hit a problem — see errors.md |

---

## Active Tasks

### TASK-001 · Supabase core schema + RLS + trigger
- **Status:** ready
- **Phase:** Phase 1 · Foundation
- **Spec:** *(no spec needed — data_structure.md is the source of truth)*
- **What to build:**
  - Run the SQL in `docs/data_structure.md` in the Supabase dashboard to create:
    - `organizations` table
    - `profiles` table (1:1 with auth.users)
    - `org_members` table with role field
  - Enable RLS on all three tables
  - Add RLS policies as defined in `docs/data_structure.md`
  - Deploy the auto-create-profile trigger
  - Confirm in Supabase dashboard that tables exist, RLS is on, trigger is deployed
- **Acceptance criteria:**
  - [ ] All three tables exist in Supabase dashboard
  - [ ] RLS is enabled on all three tables
  - [ ] RLS policies match `docs/data_structure.md`
  - [ ] Auto-create-profile trigger is deployed and working
  - [ ] Signing up a test user creates a profile row automatically
- **Files to create/modify:** None (Supabase dashboard SQL only)
- **After implementation:** Confirm in Supabase dashboard, then notify Claude for review

### TASK-002 · Core app scaffold (theme, routing, main.dart, app.dart)
- **Status:** blocked — waiting on TASK-001
- **Phase:** Phase 1 · Foundation
- **Spec:** *(reference docs/design_guidelines.md for all theme values)*
- **What to build:**
  - `lib/core/theme/app_colors.dart` — all color constants from design_guidelines.md
  - `lib/core/theme/app_text_styles.dart` — text style constants
  - `lib/core/theme/app_theme.dart` — ThemeData using above constants
  - `lib/core/constants/app_constants.dart` — app-wide constants (breakpoints, spacing)
  - `lib/core/constants/supabase_constants.dart` — Supabase URL/key loaded from dotenv
  - `lib/core/network/supabase_client_provider.dart` — Riverpod provider for Supabase client
  - `lib/core/routing/app_routes.dart` — route name constants
  - `lib/core/routing/app_router.dart` — GoRouter configuration
  - `lib/core/routing/router_notifier.dart` — auth-aware redirect logic
  - `lib/main.dart` — dotenv load, Supabase init, ProviderScope, runApp
  - `lib/app.dart` — MaterialApp.router with theme + GoRouter
- **Acceptance criteria:**
  - [ ] App runs on Flutter web with no errors
  - [ ] Unauthenticated users are redirected to `/login`
  - [ ] Theme colors match design_guidelines.md
  - [ ] No hardcoded strings or keys
  - [ ] `build_runner` runs clean
- **Files to create/modify:** See above
- **After implementation:** Run `flutter run -d chrome`, confirm redirect works, notify Claude

### TASK-003 · Auth feature (sign up, sign in, sign out)
- **Status:** blocked — waiting on TASK-002
- **Phase:** Phase 1 · Foundation
- **Spec:** *(to be written before this task starts — Claude will create specs/auth_spec.md)*
- **What to build:** Auth screens and service — to be detailed in spec
- **Acceptance criteria:** *(to be defined in spec)*
- **Files to create/modify:** *(to be defined in spec)*

### TASK-004 · Org onboarding (create org, join org)
- **Status:** blocked — waiting on TASK-003
- **Phase:** Phase 1 · Foundation
- **Spec:** *(to be written before this task starts)*
- **What to build:** Org creation and membership flow — to be detailed in spec
- **Acceptance criteria:** *(to be defined in spec)*

---

## Completed Tasks

| Task ID | Description | Completed by |
|---|---|---|

---

## Review Escalations

| Task ID | Question | Raised by | Status |
|---|---|---|---|

---

## Task Summary

| Task | Description | Depends On | Status |
|---|---|---|---|
| TASK-001 | Supabase core schema + RLS + trigger | none | ready |
| TASK-002 | Core app scaffold | TASK-001 | blocked |
| TASK-003 | Auth feature | TASK-002 | blocked |
| TASK-004 | Org onboarding | TASK-003 | blocked |

**Give Codex TASK-001 first.**
