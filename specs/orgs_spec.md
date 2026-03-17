# Orgs Spec (TASK-004)

## Overview
After sign up, `RouterNotifier` redirects users with no org membership to `/onboarding`. This screen lets the user create a new organization (their family/household). On success, they become the `owner` and are redirected to `/dashboard`.

## Scope
- Create a new organization
- Insert the creator as `owner` in `org_members`
- Out of scope: joining an existing org, inviting members, org settings

## User Stories
- As a newly signed-up user, I can create my organization so I can start using the app

## Org/User Context
- `organizations` insert: `{ name }` — id auto-generated
- `org_members` insert: `{ org_id, profile_id: auth.uid(), role: 'owner' }`
- After insert, `RouterNotifier` cache (`_cachedHasOrganization`) must be busted — call `router.refresh()` so the notifier re-queries and redirects to `/dashboard`
- RLS note: the `organizations` insert policy allows any authenticated user. The `org_members` insert policy "allow self insert as owner on org create" allows `profile_id = auth.uid()` — no special workaround needed.

## Page States
- Default: form ready
- Loading: spinner on button, input disabled
- Error: error card below form

## UI Behavior

### Onboarding screen (`/onboarding`)
- Same centered card layout as auth screens (max width 400px, `lightGray` background)
- Header: navy gradient, "Kerby Family Budget" title, "Create your organization" subtitle
- Single field: Organization Name (e.g. "Kerby Family")
- Helper text below field: "This is your household or family name."
- "Create Organization" primary button (full width, teal)
- On success: `router.refresh()` — RouterNotifier redirects to `/dashboard` automatically
- On error: red error card below form

## Data
- `supabase.from('organizations').insert({ 'name': name }).select().single()` → returns new org row
- `supabase.from('org_members').insert({ 'org_id': orgId, 'profile_id': userId, 'role': 'owner' })`
- Sequence: insert org first, get `org_id`, then insert `org_members` row
- Use `return=representation` (`.select().single()`) on org insert to get the new `id`

## Edge Cases & Rules
- Trim org name before insert; reject empty or whitespace-only names
- Capture `GoRouter.of(context)` and `ScaffoldMessenger.of(context)` before any `await`
- Do not manually navigate — call `router.refresh()` and let RouterNotifier handle redirect
- If org insert succeeds but `org_members` insert fails: show error, do not navigate. User is left at `/onboarding` to retry. (Partial state is acceptable — org row without a member is orphaned but harmless; retry will create a new org.)
- No `AuthException` in this file — no `as supa` alias needed

## Code Map

### Functions
- Create org → `lib/features/onboarding/data/org_service.dart` → `createOrg(name, userId)`

### Key Files
- Service → `lib/features/onboarding/data/org_service.dart`
- Provider → `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
- Screen → `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
