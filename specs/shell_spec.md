# Shell Spec — TASK-005

App shell + responsive navigation. Wraps all post-auth screens in a persistent layout with nav.

---

## Overview

The shell is a `StatefulShellRoute` in GoRouter that wraps the five main destinations. It renders either the mobile or desktop layout depending on screen width. Auth/onboarding routes sit outside the shell and are unaffected.

---

## Routes to Add

Add the following routes to `app_routes.dart`:

```dart
static const String monthly     = '/monthly';
static const String transactions = '/transactions';
static const String mileage     = '/mileage';
static const String business    = '/business';
static const String settings    = '/settings';

static const String monthlyName      = 'monthly';
static const String transactionsName = 'transactions';
static const String mileageName      = 'mileage';
static const String businessName     = 'business';
static const String settingsName     = 'settings';
```

Replace the existing `/dashboard` `GoRoute` with a `StatefulShellRoute.indexedStack` containing all 6 branches. The existing `_RoutePlaceholder` widget can be reused as the screen body for all branches — Codex will replace them in later tasks.

---

## Shell Layout — Breakpoint Logic

```dart
// in AppShell widget
final bool isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
return isMobile ? MobileShell(...) : DesktopShell(...);
```

---

## Desktop Shell (`lib/features/shell/layouts/desktop_shell.dart`)

### Header

Full-width navy-to-teal gradient bar.

```
background: LinearGradient(colors: [AppColors.navy, AppColors.teal], begin: Alignment.centerLeft, end: Alignment.centerRight)
height: 64px
padding: horizontal 24px
```

Contents (Column inside header):
- Row: app title left-aligned + year right-aligned
  - Title: `"Kerby Family Budget"` — `AppTextStyles.pageTitle` white
  - Year: `DateTime.now().year.toString()` — `AppTextStyles.body` white, opacity 0.8

### Tab Bar

Sits directly below the header. Full-width, navy background (`AppColors.navy`), height 44px.

Tabs (in order): **Dashboard** · **Monthly** · **Transactions** · **Mileage** · **Business** · **Settings**

Tab item rules:
- Text: 13px, SemiBold (600), white
- Inactive: no underline, white text at 70% opacity
- Active: full white text + 3px teal bottom border (`AppColors.teal`)
- Horizontal padding per tab: 20px
- Tapping a tab calls `context.go(AppRoutes.dashboard)` etc. (matching the branch index)

### Body

`Expanded` widget containing the current branch's screen, with page padding 24px horizontal.

---

## Mobile Shell (`lib/features/shell/layouts/mobile_shell.dart`)

### Top App Bar

`AppBar` with:
- Background: `AppColors.navy`
- Title: `"Kerby Family Budget"` — white, 15px Bold
- No back button (shell root screens)
- Elevation: 0

### Bottom Navigation Bar

`BottomNavigationBar` with 5 items. Type: `fixed`. Selected color: `AppColors.teal`. Unselected color: `AppColors.textMuted`. Background: white.

| Index | Label | Icon | Route |
|---|---|---|---|
| 0 | Home | `Icons.home_outlined` / `Icons.home` | `/dashboard` |
| 1 | Monthly | `Icons.calendar_month_outlined` / `Icons.calendar_month` | `/monthly` |
| 2 | _(FAB slot)_ | — | — |
| 3 | Transactions | `Icons.receipt_long_outlined` / `Icons.receipt_long` | `/transactions` |
| 4 | More | `Icons.more_horiz` | opens More bottom sheet |

Index 2 is a dummy/placeholder item — render it as an empty `BottomNavigationBarItem` with a blank label and a transparent icon. The real action is the FAB overlaid on top.

**Do not** wire the index-2 tap to any route. Ignore taps on index 2.

### FAB

Positioned center-bottom, overlapping the `BottomNavigationBar`. Use a `Stack` with `Positioned`.

```dart
FloatingActionButton(
  backgroundColor: AppColors.teal,
  foregroundColor: AppColors.white,
  shape: const CircleBorder(),
  child: const Icon(Icons.add, size: 28),
  onPressed: () => _showAddTransactionPlaceholder(context),
)
```

FAB position: centered horizontally, bottom edge aligned with bottom nav top + 28px (so it floats above the bar).

`_showAddTransactionPlaceholder` shows a `BottomSheet` with a single `ListTile`:
```
title: "Add Transaction"
subtitle: "Coming in TASK-009"
```
This placeholder is replaced in TASK-009.

### More Bottom Sheet

Tapping index 4 ("More") shows a modal bottom sheet with nav items for screens not in the bottom bar:
- Mileage → `context.go(AppRoutes.mileage)`
- Business → `context.go(AppRoutes.business)`
- Settings → `context.go(AppRoutes.settings)`

Each item: `ListTile` with leading icon, title text, `onTap` navigates and pops the sheet.

---

## File Map

| File | What |
|---|---|
| `lib/features/shell/app_shell.dart` | `AppShell` widget — breakpoint switch between mobile/desktop |
| `lib/features/shell/layouts/desktop_shell.dart` | `DesktopShell` stateless widget |
| `lib/features/shell/layouts/mobile_shell.dart` | `MobileShell` stateful widget (tracks selected index) |
| `lib/core/routing/app_routes.dart` | Add 5 new route constants |
| `lib/core/routing/app_router.dart` | Replace `/dashboard` GoRoute with `StatefulShellRoute.indexedStack` |

---

## Router Changes

Replace the existing dashboard `GoRoute` with:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      AppShell(navigationShell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: AppRoutes.dashboard, ...)]),
    StatefulShellBranch(routes: [GoRoute(path: AppRoutes.monthly, ...)]),
    StatefulShellBranch(routes: [GoRoute(path: AppRoutes.transactions, ...)]),
    StatefulShellBranch(routes: [GoRoute(path: AppRoutes.mileage, ...)]),
    StatefulShellBranch(routes: [GoRoute(path: AppRoutes.business, ...)]),
    StatefulShellBranch(routes: [GoRoute(path: AppRoutes.settings, ...)]),
  ],
)
```

Each branch builder returns `_RoutePlaceholder(title: '...', description: 'Coming soon.')` — these get replaced in later tasks.

The `RouterNotifier` redirect currently sends authenticated+org users to `/dashboard`. That stays correct — GoRouter will match `/dashboard` inside the shell.

---

## Acceptance Criteria

- [ ] `flutter run -d chrome` — desktop shell shows navy header + tab bar with all 6 tabs
- [ ] Active tab has teal underline; switching tabs updates active state
- [ ] Mobile emulation (< 600px) — top app bar + bottom nav + FAB visible
- [ ] FAB opens placeholder bottom sheet
- [ ] "More" opens bottom sheet with Mileage, Business, Settings
- [ ] All navigation uses `context.go()` — no `Navigator.push`
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` runs clean
- [ ] `flutter analyze` — zero issues

---

## Key Rules

- No `setState` anywhere — use `StatefulShellRoute`'s `navigationShell.currentIndex` for active tab tracking on desktop
- All navigation: `context.go(AppRoutes.xxx)` — never `context.push` for top-level shell tabs
- Capture `GoRouter` / `ScaffoldMessenger` before any `await`
- `build_runner` after any `@riverpod` changes (none expected in this task, but run it anyway)
