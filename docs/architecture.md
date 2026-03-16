# Architecture

> Every agent reads this file first at the start of every session. Do not skip it.

---

## System Overview

- **App name:** Personal Budget App
- **Platform:** Web (mobile + desktop breakpoints via Flutter)
- **Framework:** Flutter / Dart
- **State management:** Riverpod (`@riverpod` annotations, `riverpod_generator`)
- **Auth:** Supabase Auth
- **Database:** Supabase (Postgres)
- **Supabase project ref:** `xzjfxqkdzeawfnhfusut`
- **Supabase URL:** `https://xzjfxqkdzeawfnhfusut.supabase.co`
- **Routing:** GoRouter
- **Models:** Freezed v3.x
- **Secrets:** `flutter_dotenv` — loaded from `.env` at runtime

---

## Org / User Model

Every project uses this pattern — no exceptions.

- `organizations` — one row per family/org
- `profiles` — 1:1 with `auth.users`, auto-created via trigger on sign-up
- `org_members` — junction table linking profiles to orgs, with a `role` field (`owner | admin | member`)

All feature data is scoped to `org_id`. No query may return data without an org scope. No hardcoded IDs.

---

## Navigation Flow

`RouterNotifier` watches auth state:
- Unauthenticated → redirect to `/login`
- Authenticated, no org → redirect to `/onboarding`
- Authenticated, has org → allow through to app routes

---

## Responsive Breakpoints

| Breakpoint | Width |
|---|---|
| Mobile | < 600px |
| Tablet | 600–1200px |
| Web/Desktop | > 1200px |

Each feature has three layout files. The `_screen.dart` (layout router) selects which to render based on screen width.

---

## Known Gotchas

- **`AuthException` name clash** — in auth files, always: `import 'package:supabase_flutter/supabase_flutter.dart' as supa;`
- **`BuildContext` across async gaps** — capture `GoRouter.of(context)` and `ScaffoldMessenger.of(context)` before any `await`
- **Supabase RLS** — silent insert/update failures are almost always RLS. Check policies first
- **Edge Function imports** — use `https://esm.sh/@supabase/supabase-js@2`, never `jsr:`
- **Edge Function JWT** — "Verify JWT" is disabled on all functions; always call `supabase.auth.getUser()` manually
- **Flutter → Edge Function** — always include `headers: {'Authorization': 'Bearer ${session.accessToken}'}`

---

## `.env` Strategy

`flutter_dotenv` — loaded from `.env` at app startup via `await dotenv.load()` in `main.dart`. The `.env` file is listed in `pubspec.yaml` assets and is excluded from git via `.gitignore`. See `.env.example` for required keys.

---

## Doc Tree

```
docs/
├── architecture.md         ← you are here
├── master_plan.md
├── implementation_plan.md
├── design_guidelines.md
├── rules.md
├── agents.md
├── errors.md
├── tasks.md
└── data_structure.md

specs/
├── _spec_template.md
└── [feature]_spec.md       ← one per feature, added as features are designed
```

---

## Spec Sheet Index

> Updated as spec sheets are added.

*(none yet — added as features are designed)*

---

## Folder Conventions

```
lib/features/[feature]/
├── helpers/       — pure functions: calculations, validators, formatters, mappers
├── widgets/       — reusable UI components for this feature
├── models/        — data models specific to this feature
├── layouts/
│   ├── mobile/    — mobile UI screens (< 600px)
│   ├── tablet/    — tablet UI screens (600–1200px)
│   └── web/       — desktop UI screens (> 1200px)
├── [feature]_[page]_screen.dart     — layout router (entry point)
└── [feature]_[page]_provider.dart   — Riverpod state (shared across all layouts)
```

---

## What's Working

*(updated as features complete)*

---

## What Still Needs Building

- Phase 1: Foundation (auth, org/profile, core routing)
- Phase 2: Transactions
- Phase 3: Budget vs Actuals
- Phase 4: Reports & Charts
- Phase 5: Receipt Management

---

## Pre-Launch Dependencies

- **Apple Developer account** — not yet created. Required before App Store submission.
- **Google Play Console account** — not yet created. Required before Play Store submission.
- **Remote git repo** — created at `git@github.com:joshkerby12/Personal-Budget.git`
- **Email confirmation** — currently disabled in Supabase Auth for development. Re-enable before production launch.

---

## Maintenance Rule

After every task — whether creating a new file, adding a function, moving code, or renaming anything — both Claude and Codex must update this file. The doc tree, spec sheet index, and folder conventions must reflect the current state of the project at all times. A task is not done until the map is updated.
