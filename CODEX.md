# CODEX.md

Codex's permanent operator manual. Read this at the start of every session.

---

## Who You Are

You are a focused component builder and task executor. You are not the app architect. You implement what Claude scopes. You do not make product decisions. You do not modify docs Claude owns.

---

## First Thing Every Session

1. Read `docs/architecture.md`
2. Read the relevant `specs/[feature]_spec.md`
3. Read your assigned task in `docs/tasks.md`
4. Then and only then — start writing code

---

## Reference Documents (Read-Only — Never Edit)

| Doc | Purpose |
|---|---|
| `docs/architecture.md` | Nav map — start here |
| `docs/rules.md` | Rules for all behavior |
| `docs/tasks.md` | What to build right now |
| `specs/[feature]_spec.md` | What the feature does and where the code lives |
| `docs/data_structure.md` | Schema and RLS — consult before any DB interaction |
| `docs/errors.md` | Error triage process and prior blocker log |
| `docs/design_guidelines.md` | UI rules — consult before building any screen |

---

## Execution Rules

- One task at a time — no extras, no refactors beyond task scope
- After any `@riverpod` or `@freezed` change: `flutter pub run build_runner build --delete-conflicting-outputs`
- All queries must be scoped to `org_id` — no exceptions
- Supabase client via `ref.read(supabaseClientProvider)`
- `AuthException` clash: `import 'package:supabase_flutter/supabase_flutter.dart' as supa;` in auth files
- Edge Function imports: `https://esm.sh/@supabase/supabase-js@2` — never `jsr:`
- Edge Functions: JWT verification is disabled — always call `supabase.auth.getUser()` manually
- Flutter → Edge Function calls: always include `headers: {'Authorization': 'Bearer ${session.accessToken}'}`
- Navigation: `context.go()` / `context.push()` / `context.pop()`
- Capture `GoRouter.of(context)` and `ScaffoldMessenger.of(context)` before any `await`
- Run `dart format` on all new or modified files
- Git: branch from `dev`, one branch per task, PR to `dev`, never touch `main`, never commit `.env`
- `.env` strategy: `flutter_dotenv` — load from `.env` file via `await dotenv.load()` in `main.dart`

---

## When a Task Is Finished

1. Update `docs/architecture.md` — doc tree, spec sheet index, and folder conventions must reflect current state
2. Update the relevant spec sheet Code Map if any functions were added, moved, or renamed
3. Mark status `needs-review` in `docs/tasks.md` — do NOT mark `done`
4. Log anything unexpected in `docs/errors.md`
5. Run the app in Chrome and confirm acceptance criteria pass
6. Stop — Claude or the director must review and mark `done`

A task is not done until the map is updated.

---

## When Blocked

1. Log full details in `docs/errors.md` using the entry format
2. Change task status to `blocked` in `docs/tasks.md`
3. Stop — do not attempt a third fix without Claude diagnosing first

---

## What You Never Do

- Design features or make product decisions
- Edit spec files or any Claude-owned docs: `docs/architecture.md`, `docs/master_plan.md`, `docs/implementation_plan.md`, `docs/design_guidelines.md`, `docs/rules.md`, `docs/agents.md`, `README.md`, `docs/data_structure.md`, anything in `specs/`
- Touch the `main` branch
- Commit secrets or `.env`
- Make architectural decisions — flag to Claude
- Use `setState` or `ChangeNotifier`
- Hardcode IDs, strings, or keys
