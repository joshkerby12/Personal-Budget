# Mileage Spec — TASK-009

Mileage log feature: model, service, calculation helpers, and full UI (list + add/edit form). Parallel to TASK-006/007/008 — only depends on TASK-005 (shell nav).

---

## Overview

Users log business trips by entering origin, destination, miles, and purpose. The app calculates deductible miles and dollar value using the IRS rate stored in `app_settings`. Trips are org-scoped and user-attributed.

---

## Data Model

### `MileageTrip` (Freezed)

File: `lib/features/mileage/models/mileage_trip.dart`

```dart
@freezed
class MileageTrip with _$MileageTrip {
  const factory MileageTrip({
    required String id,
    required String orgId,
    required String createdBy,
    required DateTime date,
    required String purpose,
    required String fromAddress,
    required String toAddress,
    required double oneWayMiles,
    required bool isRoundTrip,
    required double bizPct,
    required String category,
    required DateTime createdAt,
  }) = _MileageTrip;

  factory MileageTrip.fromJson(Map<String, dynamic> json) => _$MileageTripFromJson(json);
}
```

JSON key mapping:
- `org_id` → `orgId`
- `created_by` → `createdBy`
- `from_address` → `fromAddress`
- `to_address` → `toAddress`
- `one_way_miles` → `oneWayMiles`
- `is_round_trip` → `isRoundTrip`
- `biz_pct` → `bizPct`
- `created_at` → `createdAt`

---

## Calculation Helpers

File: `lib/features/mileage/helpers/mileage_calculations.dart`

Pure functions — no Supabase, no providers, no state.

```dart
/// Total miles driven (doubles one-way if round trip)
double totalMiles(double oneWayMiles, bool isRoundTrip) {
  return isRoundTrip ? oneWayMiles * 2 : oneWayMiles;
}

/// Miles eligible for IRS deduction
double deductibleMiles(double total, double bizPct) {
  return total * bizPct;
}

/// Dollar value of deduction
double deductibleValue(double dedMiles, double irsRatePerMile) {
  return dedMiles * irsRatePerMile;
}
```

---

## Service

File: `lib/features/mileage/data/mileage_service.dart`

```dart
class MileageService {
  const MileageService(this._client);
  final SupabaseClient _client;

  Future<List<MileageTrip>> fetchTrips(String orgId, {int? year, int? month}) async { ... }
  Future<void> insertTrip(MileageTrip trip) async { ... }
  Future<void> updateTrip(MileageTrip trip) async { ... }
  Future<void> deleteTrip(String tripId) async { ... }
}
```

- `fetchTrips` — query `mileage_trips` where `org_id = orgId`, optional year/month filter, order by `date DESC`
- `insertTrip` — insert; set `created_by` to `client.auth.currentUser!.id`
- `updateTrip` — update by `id`
- `deleteTrip` — delete by `id`

---

## Providers

File: `lib/features/mileage/presentation/providers/mileage_provider.dart`

```dart
@Riverpod(keepAlive: true)
MileageService mileageService(Ref ref) =>
    MileageService(ref.watch(supabaseClientProvider));

@riverpod
class MileageController extends _$MileageController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveTrip(MileageTrip trip, {bool isEdit = false}) async { ... }
  Future<void> deleteTrip(String tripId) async { ... }
}

@riverpod
Future<List<MileageTrip>> mileageTrips(Ref ref, String orgId, {int? year, int? month}) async {
  return ref.read(mileageServiceProvider).fetchTrips(orgId, year: year, month: month);
}
```

Run `build_runner` after creating this file.

---

## IRS Rate

The IRS rate comes from `app_settings.irs_rate_per_mile` for the org. For TASK-009, use a hardcoded fallback of `0.670` if `app_settings` is not yet available (TASK-007 builds settings). Add a `TODO(TASK-007): replace with appSettingsProvider` comment.

---

## UI

### Summary Tiles (4 tiles, horizontal row)

| Tile | Value | Color |
|---|---|---|
| Total Trips | count of trips | teal left border |
| Total Miles | sum of `totalMiles()` | teal left border |
| Deductible Miles | sum of `deductibleMiles()` | green left border |
| Deductible Value | sum of `deductibleValue()` formatted as $ | green left border |

Use the same stat card style as the rest of the app (white card, 4px left accent border, 24px bold amount, 11px muted label).

---

### Mobile Layout

File: `lib/features/mileage/layouts/mobile/mileage_mobile_screen.dart`

- Summary tiles in a 2×2 grid at top
- Scrollable list of trip cards below
- Each trip card:
  - Bold purpose text
  - Date (formatted `MMM d, yyyy`)
  - Miles + "mi" label
  - Deductible value in green (`$X.XX deductible`)
  - Tap → opens Add/Edit bottom sheet in edit mode
- FAB or "+" button to add new trip (opens bottom sheet)
- Empty state: icon + "No trips logged yet" + "Tap + to add your first trip"

---

### Desktop Layout

File: `lib/features/mileage/layouts/web/mileage_web_screen.dart`

- Summary tiles in a row at top
- Toolbar: year dropdown + month dropdown ("All Months") + "Add Trip" button (teal, right-aligned)
- Table with sticky navy header row:

| Date | Purpose | From | To | Miles | Round Trip | Biz% | Ded. Miles | Ded. Value | Actions |
|---|---|---|---|---|---|---|---|---|---|

- Alternating row colors (white / lightGray)
- Actions column: edit icon (`Icons.edit_outlined`) + delete icon (`Icons.delete_outline`, red)
- Empty state row spanning all columns

---

### Layout Router

File: `lib/features/mileage/mileage_screen.dart`

```dart
class MileageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile ? const MileageMobileScreen() : const MileageWebScreen();
  }
}
```

Wire this into `app_router.dart` for the `/mileage` branch (replace the `_RoutePlaceholder`).

---

### Add/Edit Form

**Mobile:** `showModalBottomSheet`
**Desktop:** `showDialog` with `AlertDialog` (max width 540px)

Fields:

| Field | Widget | Notes |
|---|---|---|
| Date | `TextFormField` + date picker | required, defaults to today |
| Purpose | `TextFormField` | required |
| From Address | `TextFormField` | required |
| To Address | `TextFormField` | required |
| Miles (one way) | `TextFormField` (number) | required, > 0 |
| Round Trip? | `DropdownButtonFormField` (Yes/No) | default No |
| Business % | `TextFormField` (number 0–100) | default 100 |
| Category | `DropdownButtonFormField` | hardcode list for now: `['Business - Travel', 'Business - Client', 'Business - Other']`. TODO(TASK-007): replace with category provider |

**Live preview box** (shows when miles > 0):
- Light green background (`AppColors.greenFill`)
- Text: `"$X.XX deductible (Y.Y miles)"`
- Updates as user types

**Validation:**
- Date required
- Purpose required
- From/To required
- Miles > 0
- Biz% 0–100

**Buttons:**
- Cancel (ghost button)
- Save Trip / Update Trip (primary teal button)

On save: call `MileageController.saveTrip`, show `SnackBar` "Trip saved", close sheet/dialog, invalidate `mileageTripsProvider`.
On delete (edit mode only): confirm with `AlertDialog` "Delete this trip?" → call `MileageController.deleteTrip`, show "Trip deleted", pop.

---

## File Map

| File | What |
|---|---|
| `lib/features/mileage/models/mileage_trip.dart` | Freezed model |
| `lib/features/mileage/models/mileage_trip.freezed.dart` | generated |
| `lib/features/mileage/models/mileage_trip.g.dart` | generated |
| `lib/features/mileage/helpers/mileage_calculations.dart` | pure calculation functions |
| `lib/features/mileage/data/mileage_service.dart` | Supabase CRUD |
| `lib/features/mileage/presentation/providers/mileage_provider.dart` | Riverpod providers |
| `lib/features/mileage/presentation/providers/mileage_provider.g.dart` | generated |
| `lib/features/mileage/presentation/widgets/mileage_form.dart` | shared form widget (used by both layouts) |
| `lib/features/mileage/layouts/mobile/mileage_mobile_screen.dart` | mobile list + tiles |
| `lib/features/mileage/layouts/web/mileage_web_screen.dart` | desktop table + tiles |
| `lib/features/mileage/mileage_screen.dart` | layout router |
| `lib/core/routing/app_router.dart` | replace `/mileage` placeholder with `MileageScreen()` |

---

## Acceptance Criteria

- [ ] `MileageTrip` Freezed model generates cleanly
- [ ] `mileage_calculations.dart` — all three helpers correct (unit-testable)
- [ ] Mobile: summary tiles + trip list + add/edit bottom sheet functional
- [ ] Desktop: summary tiles + table + add/edit dialog functional
- [ ] Live deductible preview updates as miles/biz% changes
- [ ] Save, edit, and delete all work end-to-end
- [ ] Empty state shown when no trips
- [ ] `flutter analyze` — zero issues
- [ ] `build_runner` runs clean

---

## Key Rules

- `build_runner` after all `@riverpod` and `@freezed` changes
- Org scope on every Supabase query
- Capture `GoRouter`/`ScaffoldMessenger` before any `await`
- IRS rate hardcoded to `0.670` with `TODO(TASK-007)` comment — do not block on settings
