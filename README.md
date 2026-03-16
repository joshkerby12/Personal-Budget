# Personal Budget App

A family budget tracker covering personal and business finances. Built with Flutter (web), Supabase, and Riverpod.

---

## Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart (web) |
| State management | Riverpod (`@riverpod` annotations) |
| Auth | Supabase Auth |
| Database | Supabase (Postgres) |
| Routing | GoRouter |
| Models | Freezed v3 |
| Secrets | flutter_dotenv |

---

## Org / User Model

Every user belongs to an organization (family). All data is scoped to `org_id`. Tables:
- `organizations` — one row per family
- `profiles` — 1:1 with `auth.users`, auto-created on sign-up
- `org_members` — links profiles to orgs with a role (`owner | admin | member`)

---

## Folder Structure

```
lib/
  core/         — theme, routing, network, shared widgets
  features/     — one folder per feature (auth, budget, transactions, reports, receipts)
    [feature]/
      helpers/        — pure calculation/validation/formatting functions
      widgets/        — reusable UI components
      models/         — Freezed data models
      layouts/
        mobile/       — mobile screens (< 600px)
        tablet/       — tablet screens (600–1200px)
        web/          — desktop screens (> 1200px)
      [feature]_[page]_screen.dart    — layout router
      [feature]_[page]_provider.dart  — Riverpod state
  main.dart
  app.dart

docs/           — architecture, plan, guidelines, rules, tasks, schema
specs/          — one spec per feature
assets/
  prompts/      — AI system prompt .txt files (future)
```

---

## Dev Setup

1. Copy `.env.example` to `.env` and fill in Supabase values:
   ```
   cp .env.example .env
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run code generation:
   ```
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Link Supabase:
   ```
   supabase login
   supabase link --project-ref xzjfxqkdzeawfnhfusut
   ```
5. Run the app:
   ```
   flutter run -d chrome
   ```

---

## Docs

See [`docs/architecture.md`](docs/architecture.md) for the full doc tree and project map.
