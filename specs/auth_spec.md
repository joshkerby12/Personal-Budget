# Auth Spec

## Overview
Handles user sign up, sign in, sign out, and password reset. Uses Supabase Auth. The auto-create-profile trigger fires on sign up — no manual profile insert needed in app code.

## Scope
- Email + password sign up
- Email + password sign in
- Sign out
- Forgot password (sends reset email via Supabase)
- Out of scope: OAuth/social login, magic links, phone auth

## User Stories
- As a new user, I can sign up with email and password so I can access the app
- As a returning user, I can sign in so I can see my budget data
- As a signed-in user, I can sign out so my account is secure
- As a user who forgot their password, I can request a reset email

## Org/User Context
- Sign up creates a `profiles` row automatically via the `handle_new_user` trigger
- After sign up/sign in, `RouterNotifier` checks for org membership → redirects to `/onboarding` if none exists
- No org_id scoping needed in auth — profiles are per-user not per-org

## Page States

### Sign In screen
- Default: form ready
- Loading: spinner on button, inputs disabled
- Error: error message below form (e.g. "Invalid email or password")

### Sign Up screen
- Default: form ready
- Loading: spinner on button, inputs disabled
- Error: validation errors inline, or Supabase error below form

### Forgot Password screen
- Default: email input
- Loading: spinner
- Success: "Check your email for a reset link" message
- Error: error message below form

## UI Behavior

### Sign In screen (`/login`)
- Centered card, max width 400px, on `lightGray` background
- Header: navy gradient, "Kerby Family Budget" title, "Sign in to continue" subtitle
- Fields: Email, Password (obscured, toggle visibility icon)
- "Sign In" primary button (full width, teal)
- "Forgot password?" text link below button
- "Don't have an account? Sign up" link at bottom
- On success: RouterNotifier handles redirect automatically (no manual navigation)
- On error: show Supabase error message in a red error card below the form

### Sign Up screen (`/signup`)
- Same card layout as sign in
- Fields: Full Name, Email, Password, Confirm Password
- "Create Account" primary button (full width, teal)
- "Already have an account? Sign in" link at bottom
- Validation: all fields required, passwords must match, password min 6 chars
- On success: RouterNotifier redirects to `/onboarding`

### Forgot Password screen (`/forgot-password`)
- Same card layout
- Fields: Email only
- "Send Reset Link" button
- Back to sign in link
- On success: show success message, hide form

## Layouts
All auth screens are single-column centered cards — no mobile/tablet/web layout split needed. Same layout at all breakpoints, card just has a max width of 400px.

## Data
- `supabase.auth.signInWithPassword({email, password})`
- `supabase.auth.signUp({email, password, data: {full_name}})`
- `supabase.auth.signOut()`
- `supabase.auth.resetPasswordForEmail(email)`
- No direct table reads/writes — trigger handles profile creation

## Edge Cases & Rules
- `AuthException` name clash: always `import 'package:supabase_flutter/supabase_flutter.dart' as supa;` in auth files
- Capture `GoRouter.of(context)` and `ScaffoldMessenger.of(context)` before any `await`
- Do not manually navigate after sign in/up — let `RouterNotifier` handle it
- Show loading state immediately on button tap — prevent double submission
- "Invalid login credentials" is Supabase's generic error for wrong email/password — display as-is

## Open Questions
None — ready to implement.

---

## Code Map

### Functions
- Sign in → `lib/features/auth/data/auth_service.dart` → `signIn(email, password)`
- Sign up → `lib/features/auth/data/auth_service.dart` → `signUp(email, password, fullName)`
- Sign out → `lib/features/auth/data/auth_service.dart` → `signOut()`
- Forgot password → `lib/features/auth/data/auth_service.dart` → `sendPasswordReset(email)`
- Auth state provider → `lib/features/auth/presentation/providers/auth_provider.dart` → `authStateProvider`

### Key Files
- Service → `lib/features/auth/data/auth_service.dart`
- Provider → `lib/features/auth/presentation/providers/auth_provider.dart`
- Sign in screen → `lib/features/auth/presentation/screens/sign_in_screen.dart`
- Sign up screen → `lib/features/auth/presentation/screens/sign_up_screen.dart`
- Forgot password screen → `lib/features/auth/presentation/screens/forgot_password_screen.dart`
