# Agents

Who the agents are, what they own, and how they hand off.

---

## Agent Roster

| Agent            | Role             | Scope                                                                  |
|------------------|------------------|------------------------------------------------------------------------|
| Claude (VS Code) | Architect        | Planning, architecture, error diagnosis, task assignment, doc updates  |
| Codex            | Executor         | Multi-file task execution, code writing, terminal commands             |
| Copilot          | Inline assistant | Autocomplete, quick single-file suggestions while typing               |

---

## Claude Owns

- Walking the director through new project setup
- Breaking down features into tasks in `docs/tasks.md`
- Writing and updating all docs: `architecture.md`, spec sheets, `rules.md`, `agents.md`, `design_guidelines.md`, `master_plan.md`, `implementation_plan.md`
- Diagnosing all errors before Codex touches anything
- Reviewing Codex output when flagged
- All architectural and structural decisions
- Supabase schema changes — review and approval only

## Codex Owns

- Executing tasks assigned in `docs/tasks.md`
- Writing and editing code within defined spec
- Running terminal commands (`flutter pub get`, `build_runner`, `supabase` CLI)
- Marking tasks `done` in `docs/tasks.md` and moving them to the Completed Tasks table
- Logging blockers in `docs/errors.md`
- Following folder conventions from `docs/architecture.md`

## Copilot Owns

- Inline code completion while actively typing
- Quick single-file suggestions in the moment
- Boilerplate acceleration only — not spec-aware

---

## Handoff Rules

- Claude scopes and assigns all tasks in `docs/tasks.md` before Codex starts
- Codex does not make architectural decisions — flags to Claude
- If Codex hits ambiguity mid-task, it stops and notes the blocker in `docs/tasks.md`
- Claude diagnoses all errors before Codex attempts a fix
- Any Supabase schema change requires Claude review before execution
- Copilot suggestions are not spec-aware — always verify against `docs/rules.md` and the relevant spec

---

## Escalation

- Codex cannot resolve error after 2 attempts → stop, log in `docs/errors.md`, notify Claude
- Architectural question arises during execution → pause, ask Claude
- Copilot suggestion conflicts with spec → ignore suggestion, follow spec
