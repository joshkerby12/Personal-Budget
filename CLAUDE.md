# CLAUDE.md

Claude Code project configuration. Read automatically at the start of every session.

---

## Permissions

This is a trusted solo-developer project. All tool calls should be auto-approved: reads, edits, writes, and Bash commands.

---

## Project Identity

- **App name:** Personal Budget App
- **Bundle ID:** com.joshkerby.personalbudget
- **Working directory:** `/Users/joshkerby/Documents/Apps/Personal Budget App`
- **Platform:** Flutter web (mobile + desktop breakpoints)
- **Backend:** Supabase — project ref `xzjfxqkdzeawfnhfusut`
- **Remote git:** `git@github.com:joshkerby12/Personal-Budget.git`

---

## How This Project Works

This project uses a three-agent model:

| Agent | Role |
|---|---|
| **Claude** (you) | Architect — planning, specs, error diagnosis, task authoring, all doc updates |
| **Codex** | Executor — picks up tasks from `docs/tasks.md`, writes code, runs terminal commands |
| **Copilot** | Inline assistant — autocomplete only, not spec-aware |

Claude scopes and assigns all tasks. Codex implements and marks tasks done. No review step — issues get handled if they surface.

---

## Key Docs

| File | Purpose |
|---|---|
| `docs/architecture.md` | Root of doc tree — start here every session |
| `docs/master_plan.md` | What the app is and why |
| `docs/implementation_plan.md` | Ordered build roadmap, phase by phase |
| `docs/design_guidelines.md` | UI/UX rules — reference before building any screen |
| `docs/rules.md` | How all agents must behave |
| `docs/agents.md` | Who does what, handoff rules |
| `docs/errors.md` | Error log + triage process |
| `docs/tasks.md` | Active task queue |
| `docs/data_structure.md` | Full Supabase schema and RLS patterns |
| `specs/` | One spec per feature — created by Claude before Codex starts |

---

## Critical Rules

1. **RLS always** — every Supabase table has RLS enabled. Silent failures = RLS. Check policies first.
2. **Org scoping always** — every query must be scoped to `org_id`. No exceptions. No hardcoded IDs.
3. **Never touch `main`** — all work on `dev` or feature branches. PRs to `dev` only.
4. **Never commit `.env`** — secrets stay local. `.env` is in `.gitignore`.
5. **Riverpod only** — no `setState`, no `ChangeNotifier`. `@riverpod` annotations everywhere.
6. **`build_runner` after every `@riverpod` or `@freezed` change** — `flutter pub run build_runner build --delete-conflicting-outputs`
7. **Docs stay current** — `docs/architecture.md` must reflect the current state of the project after every task. A task is not done until the map is updated.
8. **Task review flow** — Codex marks tasks `done` and moves them to the Completed Tasks table himself. No review step required. If an issue surfaces, it gets handled then.

---

## `.env` Strategy

`flutter_dotenv` — loaded in `main.dart` via `await dotenv.load()`. File is in `pubspec.yaml` assets and excluded from git.
