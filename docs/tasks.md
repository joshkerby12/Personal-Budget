# Tasks

Active task queue. Claude authors and scopes all tasks. Codex picks up `ready` tasks and implements them.

---

## Status Rules — Non-Negotiable

### Codex must:
1. When you **start** a task → change status from `ready` to `in-progress`
2. When you **finish** a task → mark status `done`, move it to the **Completed Tasks** table (summary line only), and check if the next dependent task can now be unblocked
3. When you are **blocked** → change status to `blocked`, log in `docs/errors.md`, stop immediately

---

## Status Key

| Status | Meaning |
|---|---|
| `ready` | Scoped by Claude, ready for Codex to pick up |
| `in-progress` | Codex is actively working on it |
| `done` | Completed — moved to Completed Tasks table by Codex |
| `blocked` | Codex hit a problem — see `docs/errors.md` |

---

## Active Tasks

---

### TASK-036 · Pantry & Plan — Phase 1: Shell refactor + app mode toggle
- **Status:** done
- **Depends on:** none (isolated shell changes)
- **Scope:** Refactor the existing mobile and desktop shells to support two app modes (budget / pantry), add the mode toggle in the bottom-right nav slot, and move the "More" items to a hamburger menu. No pantry screens yet — just the chrome.

  **1. Add `AppMode` enum + provider**
  - Create `lib/core/providers/app_mode_provider.dart`
  - `enum AppMode { budget, pantry }`
  - `@riverpod AppMode appMode(AppModeRef ref) => AppMode.budget;` (using `StateProvider` pattern, not `@riverpod` — make it a `StateProvider<AppMode>` so it's mutable)
  - Run `build_runner` — no generated file needed for a plain `StateProvider`

  **2. Mobile shell refactor (`lib/features/shell/layouts/mobile_shell.dart`)**
  - Add a hamburger `IconButton` to the `AppBar` (trailing/actions) that calls the existing `_showMoreSheet` (Mileage, Business, Settings) — no changes to the sheet itself
  - Remove the phantom center slot from `BottomNavigationBar`. Replace with 4 real tabs:
    - Budget mode: Home, Monthly, Transactions, + (mode toggle)
    - Pantry mode: Lists, Meals, Deals, Pantry (last slot still has mode toggle)
  - The **4th bottom nav slot** is the mode toggle in both modes:
    - Budget mode: shows a 🛒 cart icon, label "Pantry" — tapping switches to `AppMode.pantry` and navigates to `/pantry/lists`
    - Pantry mode: shows a 💰 wallet icon, label "Budget" — tapping switches to `AppMode.budget` and navigates to `/dashboard`
    - Style this slot distinctly: teal background pill or colored icon to make it feel like a toggle, not a plain nav item
  - Center FAB stays as `+` add-transaction in budget mode. In pantry mode, FAB action is tab-aware:
    - Lists tab → open add-item bottom sheet (stub for now: just a snackbar "Add item — coming soon")
    - Meals tab → open add-meal bottom sheet (stub)
    - Deals tab → no FAB (hide it)
    - Pantry tab → no FAB (hide it)
  - `_bottomNavIndexForBranch` and `_onBottomNavTapped` updated to match new 4-item layout
  - Read `appModeProvider` to decide which tab labels/icons/routes to use

  **3. Desktop shell refactor (`lib/features/shell/layouts/desktop_shell.dart`)**
  - Add a mode toggle button on the far right of the top header bar (the gradient bar)
  - Budget mode: button reads "Pantry & Plan →", switches to `AppMode.pantry`, navigates to `/pantry/lists`
  - Pantry mode: button reads "← Budget", switches to `AppMode.budget`, navigates to `/dashboard`
  - In pantry mode, the tab row swaps to pantry tabs: Lists, Meals, Deals, Pantry (routes `/pantry/lists`, `/pantry/meals`, `/pantry/deals`, `/pantry/pantry`)
  - All existing budget tabs unchanged in budget mode

  **4. Stub routes for pantry mode**
  - Add 4 new routes to `app_router.dart` inside a new `StatefulShellBranch` group (or as top-level `GoRoute`s for now — use whatever is simplest, can be reorganized in Phase 2):
    - `/pantry/lists` → `PantryPlaceholderScreen(title: 'Shopping Lists')`
    - `/pantry/meals` → `PantryPlaceholderScreen(title: 'Meal Plan')`
    - `/pantry/deals` → `PantryPlaceholderScreen(title: 'Deals')`
    - `/pantry/pantry` → `PantryPlaceholderScreen(title: 'Pantry')`
  - `PantryPlaceholderScreen` is a simple centered `Text` widget — put it in `lib/features/pantry/pantry_placeholder_screen.dart`
  - Add route constants to `lib/core/routing/app_routes.dart`

  **5. Run `build_runner`** after any Riverpod changes.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-037 · Pantry & Plan — Phase 2: Data layer
- **Status:** done
- **Depends on:** TASK-036
- **Scope:** Full Supabase data layer for all five pantry tables. Models, services, providers. No UI yet.

  **Models** — all Freezed, all in `lib/features/pantry/models/`:
  - `pantry_store.dart` — `PantryStore { id, orgId, name, sortOrder, createdAt }`
  - `pantry_item.dart` — `PantryItem { id, orgId, storeId, name, qty, unit, category, checked, isStocked, price, createdAt }`
  - `pantry_stocked_item.dart` — `PantryStockedItem { id, orgId, name, isActive, createdAt }`
  - `pantry_meal.dart` — `PantryMeal { id, orgId, name, ingredients, costPerServing, servings, source, url, createdAt }`
  - `pantry_meal_plan_entry.dart` — `PantryMealPlanEntry { id, orgId, mealId, planDate, createdAt }`
  - `pantry_deal.dart` — `PantryDeal { id, orgId, storeName, itemName, category, salePrice, originalPrice, unit, expiresAt, createdAt }`
  - Run `build_runner` after all models.

  **Services** — all in `lib/features/pantry/data/`:
  - `pantry_store_service.dart` — `fetchStores(orgId)`, `createStore(orgId, name)`, `deleteStore(storeId)`
  - `pantry_item_service.dart` — `fetchItems(orgId, storeId)`, `createItem(...)`, `updateItem(...)`, `deleteItem(itemId)`, `checkItem(itemId, checked)`, `clearChecked(orgId, storeId)`
  - `pantry_stocked_service.dart` — `fetchStocked(orgId)`, `upsertStocked(orgId, name, isActive)`, `deleteStocked(storeId)`
  - `pantry_meal_service.dart` — `fetchMeals(orgId)`, `createMeal(...)`, `updateMeal(...)`, `deleteMeal(mealId)`
  - `pantry_meal_plan_service.dart` — `fetchPlanForWeek(orgId, weekStart)`, `addToPlan(orgId, mealId, date)`, `removeFromPlan(entryId)`
  - `pantry_deal_service.dart` — `fetchDeals(orgId)`, `seedSampleDeals(orgId)` (inserts ~10 static sample rows if table is empty)

  **Providers** — all in `lib/features/pantry/presentation/providers/pantry_providers.dart`:
  - `pantryStoresProvider(orgId)` — `FutureProvider`, fetches stores
  - `pantryItemsProvider(orgId, storeId)` — `FutureProvider`, fetches items for one store
  - `pantryStockedProvider(orgId)` — `FutureProvider`, fetches stocked items
  - `pantryMealsProvider(orgId)` — `FutureProvider`, fetches meal library
  - `pantryMealPlanProvider(orgId, weekStart)` — `FutureProvider`, fetches plan entries for the week
  - `pantryDealsProvider(orgId)` — `FutureProvider`, fetches deals
  - All use `@riverpod` annotations. Run `build_runner` after.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-038 · Pantry & Plan — Phase 3: Shopping Lists screen
- **Status:** done
- **Depends on:** TASK-037
- **Scope:** Full Shopping Lists feature. Replace the `/pantry/lists` placeholder with the real screen.

  **Reference:** [pantry-planner.jsx](../pantry-planner.jsx) — the React prototype. Rebuild in Flutter matching the design and interaction model described there and in `pantry-and-plan-scope.md` section 5.1.

  **Screen file:** `lib/features/pantry/shopping_lists/shopping_lists_screen.dart`

  **Features to build:**
  - Horizontal-scroll store pill tabs at top, with item-count badge per store. "+" tab to add a new store (opens a bottom sheet with a name text field + Add button)
  - Thin progress bar below store tabs (checked / total items)
  - Sticky add-item text input at top of list — submits on Enter or tap of Add. Auto-categorizes the item using a `_categorize(name)` helper (keyword matching, see scope doc section 7). Auto-tags `isStocked` if name matches any active stocked item from `pantryStockedProvider`
  - Items grouped by category, each group with emoji + label header
  - Each item row: checkbox, name, qty badge if > 1, stocked badge, price if set, ✕ remove button
  - Tap checkbox → `checkItem`. Tap 📦 → toggle `isStocked` (upserts to `pantry_stocked`). Tap ✕ → `deleteItem`
  - "Clear checked" button (appears when any items are checked) — calls `clearChecked`
  - Stocked items quick-add sheet: accessible from list header button. Shows all active stocked items as tappable chips → adds to current store list
  - Empty state when no stores: prompt to add a store
  - Empty state when store has no items: prompt to add an item + button to open stocked sheet
  - FAB in mobile shell is already wired in Phase 1 to open the add-item input focus (or just autofocus the sticky input when visible)
  - Desktop layout: same screen, max-width constrained, no bottom sheet for FAB — add-item input is always visible at top

  **State:** all reads/writes go through providers + services (no local setState for data). Use `ref.invalidate` to refresh after mutations.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-039 · Pantry & Plan — Phase 4: Meal Plan screen
- **Status:** done
- **Depends on:** TASK-037
- **Scope:** Full Meal Plan feature. Replace the `/pantry/meals` placeholder.

  **Reference:** `pantry-and-plan-scope.md` section 5.2 and `pantry-planner.jsx`.

  **Screen file:** `lib/features/pantry/meal_plan/meal_plan_screen.dart`

  **Features to build:**
  - Week navigation: horizontal strip of 7 day chips (Mon–Sun) for the current week. Each chip shows day abbreviation + date + meal count badge. Active day highlighted
  - Budget bar below the strip: Today's estimated cost, Week's estimated total (sum of `costPerServing × servings` across all plan entries)
  - Meal cards for the active day:
    - Name, source badge (Manual / URL), total cost, cost per serving
    - Ingredient chips (first 5 visible, "+N more" label for rest)
    - ✕ remove button → deletes the `pantry_meal_plan` entry only (not the meal)
    - "Add ingredients to list" button → opens a store picker sheet; tapping a store adds all ingredients as new `pantry_items` (auto-categorized) to that store
  - "Add meal" FAB / button → bottom sheet with two modes toggled by a tab:
    - **Manual:** name field, ingredients textarea (one per line), cost per serving field, servings field → saves to `pantry_meals` and adds a `pantry_meal_plan` entry for the active day
    - **From library:** searchable list of existing meals from `pantryMealsProvider` → tap to add to active day (no duplicate guard needed in v1)
  - (URL import deferred — skip for now, add a "Import from URL — coming soon" disabled button)
  - Empty state when no meals planned for a day

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-040 · Pantry & Plan — Phase 5: Deals screen + Pantry screen
- **Status:** done
- **Depends on:** TASK-037
- **Scope:** Two remaining screens. Replace `/pantry/deals` and `/pantry/pantry` placeholders.

  **Reference:** `pantry-and-plan-scope.md` sections 5.3 and 5.4.

  **Deals screen** (`lib/features/pantry/deals/deals_screen.dart`):
  - Location text input (city or zip) — manual entry, no GPS. On submit shows a "Deals near [location]" banner (stored in local state only — no Supabase)
  - Nearby stores: 2-column grid of store name + type cards (static seed data from `seedSampleDeals`)
  - Deal cards: single-column list. Each card: category label + emoji, item name, store name, sale price, original price (struck through), unit, savings % badge, expiry date
  - Category filter chips: horizontal scroll above list — "All" + one chip per category in current deals
  - "Add to list" button on each deal card → opens store picker sheet → adds deal item to chosen store's `pantry_items`
  - Once added, button shows "✓ Added" (local state per session — no Supabase field needed)
  - On first load, call `seedSampleDeals(orgId)` if `pantryDealsProvider` returns empty

  **Pantry screen** (`lib/features/pantry/pantry_manager/pantry_screen.dart`):
  - Summary card at top: "X items stocked"
  - Custom items section: text input to add a custom stocked item by name → upserts to `pantry_stocked`. Custom items shown as removable chips (delete → `deleteStocked`)
  - Common pantry items section: 2-column grid of ~25 curated toggle buttons (flour, sugar, olive oil, rice, pasta, canned tomatoes, chicken broth, eggs, butter, milk, garlic, onion, salt, pepper, olive oil, soy sauce, hot sauce, vinegar, breadcrumbs, oats, honey, peanut butter, jam, coffee, tea). Tap to toggle `isActive` → upserts to `pantry_stocked`
  - Active common items show checkmark + green/sage styling; inactive are plain
  - Changes propagate immediately: `pantryStockedProvider` is invalidated on every toggle so shopping list auto-tag stays current

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-046 · Pantry nav — add Meals + Cookbook as separate tabs, Deals off mobile nav
- **Status:** done
- **Depends on:** TASK-036, TASK-038, TASK-040
- **Scope:** Meals (weekly planner) and Cookbook (recipe library, built in TASK-047) are now two separate tabs. Deals moves off the mobile bottom nav but stays on desktop. Mobile nav becomes: Lists | Meals | Cookbook | Pantry. Desktop nav: Lists | Meals | Cookbook | Deals | Pantry.

  **New branch layout:**
  - Branch 6  → `/pantry/lists`    → `ShoppingListsScreen`
  - Branch 7  → `/pantry/meals`    → `MealPlanScreen` (unchanged)
  - Branch 8  → `/pantry/cookbook` → `CookbookScreen` (stub — built in TASK-047)
  - Branch 9  → `/pantry/deals`    → `DealsScreen`
  - Branch 10 → `/pantry/pantry`   → `PantryScreen`
  - Total: 11 branches (0–5 budget, 6–10 pantry). `_pantryBranchStartIndex` stays 6.

  **1. `lib/core/routing/app_routes.dart`**
  - Add `static const String pantryCookbook = '/pantry/cookbook';`
  - Add `static const String pantryCookbookName = 'pantryCookbook';`
  - Keep all existing constants unchanged

  **2. `lib/core/routing/app_router.dart`**
  - Insert a new `StatefulShellBranch` at index 8 for `/pantry/cookbook` → `CookbookScreen`
  - Deals shifts to branch 9, Pantry to branch 10
  - Create `lib/features/pantry/cookbook/cookbook_screen.dart` as a placeholder: `Scaffold` with centered `Text('Cookbook — coming soon')`

  **3. Mobile shell (`lib/features/shell/layouts/mobile_shell.dart`)**
  - Pantry mode bottom nav — 4 slots, no Deals, no mode toggle in nav:
    - slot 0 → Lists (branch 6, `Icons.list_alt`)
    - slot 1 → Meals (branch 7, `Icons.calendar_today`)
    - slot 2 → Cookbook (branch 8, `Icons.menu_book_outlined`)
    - slot 3 → Pantry (branch 10, `Icons.kitchen_outlined`)
  - Mode toggle moves to AppBar `actions` as a second icon button (alongside hamburger). Budget mode AppBar keeps hamburger only — no toggle needed there since it's the default mode. Pantry mode AppBar shows: hamburger + a small "← Budget" icon button (`Icons.account_balance_wallet_outlined`) that switches mode and goes to `/dashboard`.
  - `_bottomNavIndexForBranch`: 6→0, 7→1, 8→2, 10→3. Branch 9 (Deals) has no slot — mobile reaches it via "View Deals" button in Lists screen.
  - `_onBottomNavTapped`: 0→`pantryLists`, 1→`pantryMeals`, 2→`pantryCookbook`, 3→`pantryPantry`
  - FAB: show on branches 6 (Lists) and 7 (Meals). Hide on 8 (Cookbook) and 10 (Pantry).
  - Update `_shouldShowFab` accordingly.

  **4. Desktop shell (`lib/features/shell/layouts/desktop_shell.dart`)**
  - `_pantryTabs` — all 5:
    ```dart
    _DesktopTabItem(label: 'Lists',    route: AppRoutes.pantryLists,    branch: 6),
    _DesktopTabItem(label: 'Meals',    route: AppRoutes.pantryMeals,    branch: 7),
    _DesktopTabItem(label: 'Cookbook', route: AppRoutes.pantryCookbook, branch: 8),
    _DesktopTabItem(label: 'Deals',    route: AppRoutes.pantryDeals,    branch: 9),
    _DesktopTabItem(label: 'Pantry',   route: AppRoutes.pantryPantry,   branch: 10),
    ```
  - Update `_pantryBranchStartIndex` check — stays 6, but the upper bound for pantry mode detection is now branch 10.

  **5. "View Deals" button in Shopping Lists screen (`lib/features/pantry/shopping_lists/shopping_lists_screen.dart`)**
  - Add a small outlined button in the header row alongside the existing "Stocked" button: label "Deals", icon `Icons.local_offer_outlined`
  - On tap: `context.go(AppRoutes.pantryDeals)`

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-048 · Meal Plan — Breakfast / Lunch / Dinner slots
- **Status:** done
- **Depends on:** TASK-046
- **Scope:** Add meal slots (Breakfast, Lunch, Dinner) to the meal plan. Each day shows three named sections, each of which can hold one or more meals. Requires a schema migration and model update.

  **1. Supabase migration — run manually before Codex starts**
  Add a `meal_slot` column to `pantry_meal_plan`:
  ```sql
  alter table pantry_meal_plan
    add column meal_slot text not null default 'dinner'
    check (meal_slot in ('breakfast', 'lunch', 'dinner'));
  ```
  Existing rows will default to `'dinner'`. No data loss.

  **2. Model update — `lib/features/pantry/models/pantry_meal_plan_entry.dart`**
  - Add `@JsonKey(name: 'meal_slot') required String mealSlot` to `PantryMealPlanEntry`
  - Run `build_runner` after

  **3. Service update — `lib/features/pantry/data/pantry_meal_plan_service.dart`**
  - `addToPlan(orgId, mealId, date, {String mealSlot = 'dinner'})` — add `mealSlot` parameter, include in insert

  **4. Provider update — `lib/features/pantry/presentation/providers/pantry_providers.dart`**
  - No structural change needed — provider fetches all entries for the week and the screen groups by slot client-side

  **5. MealPlanScreen rewrite — `lib/features/pantry/meal_plan/meal_plan_screen.dart`**
  - The day view body changes from a flat list of meal cards to three labelled sections: **Breakfast**, **Lunch**, **Dinner**
  - Each section has a header row with the slot label + an `+` icon button to add a meal to that specific slot
  - Meal cards within each slot are unchanged
  - The top-level "Add Meal" button is removed — adding is done per-slot via the `+` button in each section header
  - Tapping `+` on a slot opens the existing add-meal sheet (library picker + "Go to Cookbook" link from TASK-047), pre-selecting that slot
  - Budget bar remains unchanged (totals across all slots for the day/week)
  - Empty slot: show a subtle "Nothing planned" placeholder row with a `+` button — don't hide the section entirely

  **6. Cookbook / add-to-plan flow update**
  - The "Add to meal plan" button on Cookbook recipe cards now needs to pick both a date AND a slot. Update the date picker sheet to include a slot selector (3 chips: Breakfast / Lunch / Dinner) above the day strip.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-047 · Cookbook screen — saved recipe library
- **Status:** done
- **Depends on:** TASK-046
- **Scope:** Build the Cookbook screen at `/pantry/cookbook`. This is the saved recipe library — browse, add, edit, and delete meals. The weekly planner (Meals tab) pulls from this library. The data layer (`pantry_meals` table, `PantryMealService`, `pantryMealsProvider`) is already fully built.

  **Screen file:** `lib/features/pantry/cookbook/cookbook_screen.dart` (replace the placeholder stub from TASK-046)

  **Layout:**
  - Page title "Cookbook"
  - Search bar at top — filters the list client-side by meal name as the user types
  - FAB (`+`) or header button "Add Recipe" → opens add/edit sheet (see below)
  - Recipe cards in a scrollable list. Each card shows:
    - Meal name (bold)
    - Ingredient count: "X ingredients"
    - Cost info if present: "$X.XX / serving · X servings"
    - Source badge: "Manual" or "URL" (small pill)
    - Row of action buttons: **Edit** (pencil icon) and **Delete** (trash icon)
    - **"Add to meal plan"** button → opens a date picker bottom sheet (7 day chips for current week, same as `_DayChip` in `MealPlanScreen`) → calls `pantryMealPlanService.addToPlan(orgId, meal.id, selectedDate)` → snackbar confirmation
  - Empty state: "No recipes yet. Add your first recipe to get started."

  **Add / Edit sheet:**
  - Same form as the existing manual entry in `MealPlanScreen` (`_ManualMealForm`): name, ingredients textarea (one per line), cost per serving, servings
  - Reuse or extract `_ManualMealForm` into a shared widget at `lib/features/pantry/widgets/meal_form.dart` so both Cookbook and MealPlanScreen use it
  - Edit pre-fills all fields from the existing `PantryMeal`
  - Save: `createMeal` for new, `updateMeal` for edits → `ref.invalidate(pantryMealsProvider(orgId))`

  **Delete:**
  - Confirmation dialog: "Delete [name]? This will also remove it from any planned days."
  - On confirm: `deleteMeal(mealId)` → `ref.invalidate(pantryMealsProvider(orgId))` + `ref.invalidate(pantryMealPlanProvider(orgId, currentWeekStart))`

  **MealPlanScreen cleanup:**
  - The "From library" picker in the add meal sheet already covers the use case of adding a library meal to a day — keep it as-is
  - Remove the manual entry form from the MealPlanScreen add sheet entirely. Redirect "Add Meal" to: show a sheet with just the library picker + a "Go to Cookbook to add a new recipe" link that navigates to `/pantry/cookbook`. This keeps recipe creation in one place.
  - The manual form is now Cookbook-only.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-045 · Pantry screen — grouped stocked items + compact chip UI + category picker
- **Status:** done
- **Depends on:** TASK-040
- **Scope:** Three related UI changes to the Pantry screen (`lib/features/pantry/pantry_manager/pantry_screen.dart`).

  **1. Group stocked items by category**
  - Both custom items and common items are currently shown as flat lists/grids. Replace the single "Common pantry items" grid with grouped sections, one per category, using `kPantryCategoryOrder` for sort order.
  - Each section has a header: `'${emoji} ${label}'` using `pantryCategoryEmoji` and `pantryCategoryLabel` from `pantry_taxonomy.dart`
  - Within each section, items are sorted alphabetically
  - Custom items that have a category assigned are placed in their matching section. Custom items with category `'other'` go in the Other section. There is no longer a separate "Custom items" section — all items live in their category group.
  - The common items list (`kCommonPantryItems`) each have a category derivable via `categorizePantryItem(name)` — use that to bucket them into the correct section

  **2. Compact chip UI**
  - Replace the current `OutlinedButton.icon` grid (which renders as large pill-shaped buttons) with compact chips
  - Each item is a small box: `borderRadius: BorderRadius.circular(6)`, padding `EdgeInsets.symmetric(horizontal: 8, vertical: 5)`, just large enough to fit the item name
  - Active (stocked) style: sage/green background (`AppColors.greenFill`), green border, green text, small checkmark icon leading
  - Inactive style: white background, light gray border (`AppColors.border`), muted text, no icon
  - Use `Wrap` within each section to flow chips naturally — no fixed 2-column grid
  - Custom items also get a small ✕ delete button (keep existing delete logic), rendered as a tiny trailing icon inside the chip

  **3. Category picker when adding a custom item**
  - The existing "Add custom pantry item" text input + Add button stays as-is
  - Add a category dropdown below (or inline after) the text input. Use a `DropdownButtonFormField<String>` populated from `kPantryCategoryOrder` with `pantryCategoryLabel` as display text
  - Default selection: auto-suggest using `categorizePantryItem(typedName)` — update the dropdown selection live as the user types
  - On submit, pass the selected category to `upsertStocked` — update `PantryStockedService.upsertStocked` signature to accept an optional `category` parameter and store it... actually `pantry_stocked` has no category column. Instead, store the category in the item name lookup: use `categorizePantryItem` as the fallback for display grouping. The category is derived at render time from the name, not stored — this keeps the schema unchanged.
  - So: no schema change needed. The dropdown is purely for UX feedback (shows the user which group the item will appear in). The actual grouping at render time always uses `categorizePantryItem(item.name)`.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-041 · Pantry — Realtime sync
- **Status:** done
- **Depends on:** TASK-037
- **Scope:** Add Supabase Realtime subscriptions to the pantry providers so both household users see live updates without manual refresh. This is the highest-priority pantry task — without it, shared use is broken.

  **What to add:**
  - In `lib/features/pantry/presentation/providers/pantry_providers.dart`, convert the following from plain `FutureProvider` to `StreamProvider` backed by Supabase Realtime:
    - `pantryStoresProvider(orgId)` — subscribe to `pantry_stores` where `org_id = orgId`
    - `pantryItemsProvider(orgId, storeId)` — subscribe to `pantry_items` where `org_id = orgId AND store_id = storeId`
    - `pantryStockedProvider(orgId)` — subscribe to `pantry_stocked` where `org_id = orgId`
    - `pantryMealsProvider(orgId)` — subscribe to `pantry_meals` where `org_id = orgId`
    - `pantryMealPlanProvider(orgId, weekStart)` — subscribe to `pantry_meal_plan` where `org_id = orgId` and `plan_date` is within the week range

  **Pattern to follow:**
  Use `supabase.from('table').stream(primaryKey: ['id']).eq('org_id', orgId)` which returns a `Stream<List<Map<String, dynamic>>>`. Map the stream output through the existing model `fromJson` constructors. Example:
  ```dart
  @riverpod
  Stream<List<PantryStore>> pantryStores(PantryStoresRef ref, String orgId) {
    return Supabase.instance.client
        .from('pantry_stores')
        .stream(primaryKey: ['id'])
        .eq('org_id', orgId)
        .map((List<Map<String, dynamic>> rows) =>
            rows.map(PantryStore.fromJson).toList());
  }
  ```
  For `pantryItemsProvider` add a second `.eq('store_id', storeId)` filter.
  For `pantryMealPlanProvider` the stream should filter by org_id only; filter by week range client-side in the provider map step (Supabase stream doesn't support range filters).

  **Important:** All screens already use `ref.watch(...)` and `.when(...)` — `StreamProvider` uses the same `.when` API as `FutureProvider`, so screen code should need no changes. Run `build_runner` after.

  **Supabase Realtime must be enabled** on each table in the Supabase dashboard → Database → Replication → enable for `pantry_stores`, `pantry_items`, `pantry_stocked`, `pantry_meals`, `pantry_meal_plan`. Note this in a comment at the top of `pantry_providers.dart`.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-042 · Pantry — Meal library management (edit + delete)
- **Status:** done
- **Depends on:** TASK-039
- **Scope:** Add edit and delete actions to meals in the meal library. Currently meals accumulate with no way to manage them.

  **Changes to `lib/features/pantry/meal_plan/meal_plan_screen.dart`:**

  **Delete meal:**
  - Add a long-press gesture (or a trailing `...` menu) on each `_MealCard` that shows a confirmation dialog: "Delete [meal name] from library? This will remove it from all planned days."
  - On confirm: call `pantryMealService.deleteMeal(mealId)`, then `ref.invalidate(pantryMealsProvider(orgId))` and `ref.invalidate(pantryMealPlanProvider(orgId, weekStart))`

  **Edit meal:**
  - Tapping the meal name on a `_MealCard` (or adding an Edit button to the card header row alongside the ✕) opens a bottom sheet pre-filled with the existing meal data (same form as manual add: name, ingredients textarea, cost per serving, servings)
  - On save: call `pantryMealService.updateMeal(meal.copyWith(...))`, then invalidate `pantryMealsProvider`
  - The edit sheet reuses the same `_ManualMealForm` widget — refactor it to accept optional initial values for all fields

  **Service method** — `updateMeal` already exists in `pantry_meal_service.dart`, so no new service code needed.

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-043 · Pantry — Shopping list item quantity + unit editing
- **Status:** done
- **Depends on:** TASK-038
- **Scope:** Let users set quantity and unit on shopping list items. Currently all items are created with qty=1 and no unit, with no way to change either.

  **Changes to `lib/features/pantry/shopping_lists/shopping_lists_screen.dart`:**

  - Tapping an item name (or a new edit icon on the item row) opens a small bottom sheet with three fields: Name, Qty (number input), Unit (text input, e.g. "lbs", "oz", "bag")
  - On save: call `pantryItemService.updateItem(item.copyWith(name: ..., qty: ..., unit: ...))`, then `ref.invalidate(pantryItemsProvider(orgId, storeId))`
  - The qty badge already renders in `_ItemRow` when `item.qty > 1` — it will show automatically after the update
  - The unit should appear alongside the qty badge: e.g. "2 lbs" in the badge

  **Update `_ItemRow`:**
  - Make the item name tappable (`InkWell` or `GestureDetector`) to open the edit sheet
  - Update the qty badge to show unit if present: `'x${qty} ${unit}'.trim()`

- **When done:** Mark `done`, move to Completed Tasks table

---

### TASK-044 · Pantry — Delete store
- **Status:** done
- **Depends on:** TASK-038
- **Scope:** Add a way to delete a store from the shopping lists screen. `deleteStore` already exists in `pantry_store_service.dart` but there's no UI.

  **Changes to `lib/features/pantry/shopping_lists/shopping_lists_screen.dart`:**

  - Long-press on a `_StorePill` opens a confirmation dialog: "Delete [store name]? This will remove all items in this list." (always warn regardless of item count — simpler)
  - On confirm: call `pantryStoreService.deleteStore(storeId)` (cascade delete handles items via FK), then `ref.invalidate(pantryStoresProvider(orgId))`
  - After delete, reset `_activeStoreIdProvider` to `null` so it falls back to the first remaining store

- **When done:** Mark `done`, move to Completed Tasks table

---

## Completed Tasks

| Task ID | Description | Completed | Notes |
|---|---|---|---|
| TASK-001 | Supabase full schema + RLS + triggers | Claude/Codex | 9 tables, RLS on all, trigger deployed, email confirm disabled |
| TASK-002 | Core app scaffold | Codex | theme, routing, dotenv, Supabase init, RouterNotifier — analyzer clean |
| TASK-003 | Auth feature | Codex | sign in/up/out/forgot password — `as supa` alias correct, no manual nav, analyzer clean |
| TASK-004 | Org onboarding | Codex | OrgService, OnboardingController, OnboardingScreen — router.refresh() after create, analyzer clean |
| TASK-005 | App shell + navigation | Codex | StatefulShellRoute, desktop header+tabs, mobile AppBar+BottomNav+FAB+More sheet — analyzer clean |
| TASK-006 | Category data layer | Codex | Category Freezed model, CategoryService, categoriesProvider, ~60 subcategory seed |
| TASK-007 | Budget defaults + Settings screen | Codex | AppSettings + BudgetDefault models, SettingsService, SettingsEditor widget, desktop + mobile layouts |
| TASK-008 | Transaction data layer | Codex | Transaction + TransactionFilter Freezed models, TransactionService, transaction_calculations helpers, providers |
| TASK-009 | Mileage Log | Codex | MileageTrip model, MileageService, mileage_calculations helpers, Add/Edit form, mobile list + desktop table |
| TASK-016 | Invite code schema + InviteService | Codex | invite_code column on organizations, OrgService updated, InviteService, inviteServiceProvider |
| TASK-017 | Onboarding fork + invite code in Settings | Codex | Choose/Create/Join flow, join confirmation dialog, invite code section in SettingsEditor |
| TASK-010 | Add/Edit Transaction form | Codex | ConsumerStatefulWidget + TextEditingController, auto biz% from defaults, live split preview, mobile sheet + desktop dialog |
| TASK-011 | Transactions list screen | Codex | Mobile month/category filters + list, desktop search/filter/table, FAB wired, empty states |
| TASK-012 | Dashboard screen | Codex | DashboardSummary provider, fl_chart bar + donut charts, category progress bars, recent transactions, year filter on desktop |
| TASK-013 | Monthly Budget View | Codex | MonthlyBudgetData provider, view/edit modes, per-month overrides, progress bars, collapsible mobile + inline desktop edit |
| TASK-015 | Receipt upload + management | Codex | Receipt Freezed model, ReceiptService (upload/download/link/delete), FilePicker, dart:html download, transaction form integration |
| TASK-014 | Business Summary screen | Codex | BusinessSummaryData provider, year/month filter, desktop table + mobile cards, mileage deduction block, wired to /business |
| TASK-018 | Teller bank integration | Codex | teller_enrollments + sync_log tables, 3 edge functions, TellerService + provider, JS interop, Settings UI, pg_cron doc |
| TASK-019 | Monthly subcategory drill-down | Codex | Desktop + mobile expand/collapse, transaction sub-rows, budget suggestion label |
| TASK-021 | Auto-categorization suggestions | Codex | recentCategorizedTransactionsProvider, merchant normalization, suggestion UI in uncategorized panel |
| TASK-022 | Missing miles panel | Codex | no_miles migration + model field, desktop missing miles panel, inline miles entry + No Miles button |
| TASK-020 | Monthly uncategorized panel | Codex | Collapsible uncategorized card in monthly view with edit-sheet routing + refresh on save |
| TASK-023 | Monthly mobile expand + desktop suggestion label | Codex | Mobile subcategory expand rows with edit/rename/delete controls; desktop prior-month suggested budget label |
| TASK-024 | Monthly per-month subcategory add | Codex | Desktop inline add + mobile bottom-sheet add for month-scoped subcategories |
| TASK-025 | Monthly default fallback fix | Codex | Provider now includes month override keys so month-scoped rows and fallback/default resolution remain intact |
| TASK-026 | Transaction form improvements | Codex | Source label for imported transactions, drag-dismiss mobile sheet, sort-order category/subcategory picker improvements |
| TASK-027 | Dashboard time range filter | Codex | Range selector (This Month/3M/6M/YTD) wired into provider + mobile/web charts and totals |
| TASK-028 | Mobile safe-area bottom padding | Codex | SafeArea bottom handling across all mobile layout screens |
| TASK-029 | Transaction form suggestion prefill | Codex | Uncategorized edit form now pre-fills merchant-history suggestion and supports blank unselected state when none |
| TASK-030 | CSV transaction import | Codex | CSV institution mapping + parse/dedup + import log tables/service/providers; desktop/mobile import flow with history drill-down |
| TASK-031 | Fix missing miles panel dismiss | Codex | Missing miles car-action now marks transaction `noMiles: true` after trip save so it dismisses from panel |
| TASK-032 | Monthly 3-month average budget suggestion | Codex | Added edit-mode "Suggest Budgets" action to prefill matching rows from prior 3-month non-zero monthly spend averages (rounded), without auto-saving |
| TASK-033 | Budgeted income vs expenses summary bar | Codex | Added budgeted income/expenses/projected net bars to monthly view and dashboard, with range-aware totals in dashboard summary provider |
| TASK-034 | Split transaction | Codex | Added `transaction_splits` schema + model/service/provider wiring, replaced split toggle UI with multi-row allocation editor, and updated monthly drill-down to show split amounts with badges |
| TASK-035 | Fix split transaction amounts in monthly provider | Codex | Monthly provider now buckets split rows by split category/subcategory (including catch-all reroute), and drill-down rows render per-subcategory split amounts from preloaded split data |
| TASK-036 | Pantry & Plan — Phase 1: Shell refactor + mode toggle | Codex | AppMode provider, hamburger menu, mode toggle in bottom-right nav slot, stub pantry routes |
| TASK-037 | Pantry & Plan — Phase 2: Data layer | Codex | 6 Freezed models, 6 services, Riverpod providers for all pantry tables |
| TASK-038 | Pantry & Plan — Phase 3: Shopping Lists screen | Codex | Full shopping lists screen with store tabs, add item, auto-categorize, stocked items, progress bar |
| TASK-039 | Pantry & Plan — Phase 4: Meal Plan screen | Codex | Full meal plan screen with week strip, meal cards, add meal sheet, ingredient-to-list flow |
| TASK-040 | Pantry & Plan — Phase 5: Deals + Pantry screens | Codex | Deals screen with filter chips + add-to-list, Pantry screen with stocked item toggles |
| TASK-041 | Pantry — Realtime sync | Codex | Pantry providers converted to realtime streams with mapped model filtering and replication note |
| TASK-042 | Pantry — Meal library management (edit + delete) | Codex | Meal cards now support edit sheet reuse and delete-from-library confirmation with provider refresh |
| TASK-043 | Pantry — Shopping list item quantity + unit editing | Codex | Item name tap opens edit sheet (name/qty/unit) and quantity badge now includes unit |
| TASK-044 | Pantry — Delete store | Codex | Long-press store pill now confirms delete, removes store, and resets active store selection |
| TASK-045 | Pantry screen — grouped items + compact chips + category picker | Codex | Grouped category sections, compact wrap chips, and live category-suggest dropdown for custom items |
| TASK-046 | Pantry nav — Meals/Cookbook tabs + Deals off mobile nav | Codex | Added cookbook branch/tab, moved mobile Deals to Shopping Lists button, and updated mobile/desktop pantry nav mapping |
| TASK-047 | Cookbook screen — saved recipe library | Codex | Built cookbook with search, add/edit/delete recipe flow, shared meal form, and add-to-plan date+slot picker |
| TASK-048 | Meal Plan — Breakfast / Lunch / Dinner slots | Codex | Added meal_slot migration/model/service updates and rewrote meal plan into slot sections with per-slot add flow |

---

## Review Escalations

| Task ID | Question | Raised by | Status |
|---|---|---|---|
| TASK-001 | Should `organizations` select/insert policies be adjusted to allow returning the new org row on insert (for onboarding), or should onboarding always insert with client-generated UUID + `return=minimal`? | Codex | resolved — use client-generated UUID (TASK-016 adds open select policy for invite lookup) |

---

## Task Summary

| Task | Description | Depends On | Status |
|---|---|---|---|
| TASK-001 | Supabase full schema | none | done |
| TASK-002 | Core app scaffold | TASK-001 | done |
| TASK-003 | Auth feature | TASK-002 | done |
| TASK-004 | Org onboarding | TASK-003 | done |
| TASK-005 | App shell + navigation | TASK-004 | done |
| TASK-006 | Category data layer | TASK-005 | done |
| TASK-007 | Budget defaults + Settings screen | TASK-006 | done |
| TASK-008 | Transaction data layer | TASK-006, TASK-007 | done |
| TASK-009 | Mileage Log | TASK-005 | done |
| TASK-016 | Invite code schema + InviteService | TASK-004 | done |
| TASK-017 | Onboarding fork + invite code in Settings | TASK-016, TASK-007 | done |
| TASK-010 | Add/Edit Transaction form | TASK-008 | done |
| TASK-011 | Transactions list screen | TASK-008, TASK-010 | done |
| TASK-012 | Dashboard screen | TASK-008 | done |
| TASK-013 | Monthly Budget View | TASK-007, TASK-008 | done |
| TASK-014 | Business Summary | TASK-008, TASK-009 | done |
| TASK-015 | Receipt upload + management | TASK-008 | done |
| TASK-018 | Teller bank integration | TASK-008, TASK-007 | done |
| TASK-019 | Monthly subcategory drill-down | TASK-013 | done |
| TASK-021 | Auto-categorization suggestions | TASK-020 | done |
| TASK-022 | Missing miles panel | TASK-013 | done |
| TASK-020 | Monthly uncategorized panel | TASK-019 | done |
| TASK-023 | Monthly mobile expand + desktop budget suggestion | TASK-019 | done |
| TASK-024 | Monthly per-month subcategory add | TASK-013 | done |
| TASK-025 | Monthly future month budget defaults fix | TASK-013 | done |
| TASK-026 | Transaction form improvements | TASK-010, TASK-018 | done |
| TASK-027 | Dashboard time range filter | TASK-012 | done |
| TASK-028 | Mobile safe area bottom padding | none | done |
| TASK-029 | Uncategorized transaction form auto-fill | TASK-021 | done |
| TASK-030 | CSV transaction import | TASK-008 | done |
| TASK-031 | Fix missing miles panel dismiss | TASK-022 | done |
| TASK-032 | Monthly 3-month average budget suggestion | TASK-013, TASK-025 | done |
| TASK-033 | Budgeted income vs expenses summary bar | TASK-013, TASK-012 | done |
| TASK-034 | Split transaction | TASK-008, TASK-010 | done |
| TASK-035 | Fix split transaction amounts in monthly provider | TASK-034 | done |
| TASK-036 | Pantry & Plan — Phase 1: Shell refactor + mode toggle | none | done |
| TASK-037 | Pantry & Plan — Phase 2: Data layer | TASK-036 | done |
| TASK-038 | Pantry & Plan — Phase 3: Shopping Lists screen | TASK-037 | done |
| TASK-039 | Pantry & Plan — Phase 4: Meal Plan screen | TASK-037 | done |
| TASK-040 | Pantry & Plan — Phase 5: Deals + Pantry screens | TASK-037 | done |
| TASK-046 | Pantry nav — Meals + Cookbook separate tabs, Deals off mobile nav | TASK-036, TASK-038, TASK-040 | done |
| TASK-047 | Cookbook screen — saved recipe library | TASK-046 | done |
| TASK-048 | Meal Plan — Breakfast / Lunch / Dinner slots | TASK-046 | done |
| TASK-045 | Pantry screen — grouped items + compact chips + category picker | TASK-040 | done |
| TASK-041 | Pantry — Realtime sync | TASK-037 | done |
| TASK-042 | Pantry — Meal library management (edit + delete) | TASK-039 | done |
| TASK-043 | Pantry — Shopping list item quantity + unit editing | TASK-038 | done |
| TASK-044 | Pantry — Delete store | TASK-038 | done |
