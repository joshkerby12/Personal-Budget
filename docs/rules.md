# Rules

How every agent must behave at all times, regardless of task. Applies to Claude, Codex, and Copilot.

---

## Coding Standards

- State management: Riverpod only — `@riverpod` annotation, never `setState`, never `ChangeNotifier`
- After any `@riverpod` or `@freezed` change: run `flutter pub run build_runner build --delete-conflicting-outputs`
- Supabase calls only in service/data layer — never direct from widgets or providers
- All edge functions in TypeScript, not JavaScript
- Edge Function imports: `https://esm.sh/@supabase/supabase-js@2` — never `jsr:`
- Edge Functions: "Verify JWT" is disabled — always call `supabase.auth.getUser()` manually
- Flutter → Edge Function calls: always include explicit auth header: `headers: {'Authorization': 'Bearer ${session.accessToken}'}`
- Helpers are pure functions — no side effects, no direct DB calls
- Models: Freezed v3.x — `@freezed` annotation, part files
- Navigation: GoRouter — `context.go()` / `context.push()` / `context.pop()`
- Async safety: capture `GoRouter.of(context)` and `ScaffoldMessenger.of(context)` before any `await`
- `AuthException` clash: use `import 'package:supabase_flutter/supabase_flutter.dart' as supa;` in auth files
- Org/user scoping: always enforce, never hardcode IDs, all queries scoped to `org_id`
- No hardcoded strings or keys — use constants
- Run `dart format` on all new files
- `.env` strategy: `flutter_dotenv` — never commit the `.env` file

---

## Agent Behavior

- Always read `docs/architecture.md` at the start of a new session before any task
- Always read the relevant spec sheet before writing any code
- Never modify more files than necessary for the task
- Ask before making any architectural decisions
- Confirm before deleting anything
- Never skip error handling to make something work quickly
- Never assume a spec — ask if unclear
- Never assume the director has given complete information — ask clarifying questions

---

## File & Folder Conventions

- Feature folder structure must follow `docs/architecture.md` conventions
- Naming: `[feature]_[page]_screen.dart`, `[feature]_[page]_provider.dart`
- Layout files: `[feature]_[page]_screen_mobile.dart`, `_tablet.dart`, `_web.dart`
- Helper files named by responsibility: `[feature]_calculations.dart`, `_validators.dart`, `_formatters.dart`
- Always update the spec sheet Code Map when adding, moving, or renaming functions
- Always update `docs/architecture.md` doc tree and spec sheet index after every task — no exceptions
- Always update `docs/tasks.md` when a task is completed — mark it `done` and move it to the Completed Tasks table yourself
- When moving a task to Completed: **delete the entire task detail block** from Active Tasks (everything from the `### TASK-XXX` heading down to the closing `---`). Only the one-line summary row in the Completed Tasks table should remain.
- A task is not complete until `docs/architecture.md` reflects the current state of the codebase

---

## What Never To Do

- Never change the Supabase schema without explicit instruction from the director
- Never refactor surrounding code while fixing a bug — fix only what is broken
- Never change data models to fix a UI issue
- Never make structural or architectural decisions — flag to Claude
- Never let a Copilot suggestion override spec behavior without verification
- Never commit `.env` or any file containing secrets
- Never touch the `main` branch — all work on `dev` or feature branches
- Never use `setState` or `ChangeNotifier` — Riverpod only
