# Transactions Spec — TASK-008, TASK-010, TASK-011

Three tasks share this spec:
- **TASK-008** — data layer only (model, service, provider, helpers)
- **TASK-010** — Add/Edit Transaction form (bottom sheet / dialog)
- **TASK-011** — Transactions list screen (mobile + desktop)

---

## TASK-008 · Transaction Data Layer

### Data Model

File: `lib/features/transactions/models/transaction.dart`

```dart
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String orgId,
    required String createdBy,
    required DateTime date,
    required double amount,
    required String merchant,
    String? description,
    required String category,
    required String subcategory,
    required double bizPct,       // 0.0–1.0
    required bool isSplit,
    String? receiptId,
    String? notes,
    required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
```

JSON mapping: `org_id` → `orgId`, `created_by` → `createdBy`, `biz_pct` → `bizPct`, `is_split` → `isSplit`, `receipt_id` → `receiptId`, `created_at` → `createdAt`

---

### Calculation Helpers

File: `lib/features/transactions/helpers/transaction_calculations.dart`

Pure functions — no Supabase, no providers, no state.

```dart
/// Dollar amount attributed to personal use
double calculatePersonalAmount(double amount, double bizPct) =>
    amount * (1 - bizPct);

/// Dollar amount attributed to business use
double calculateBusinessAmount(double amount, double bizPct) =>
    amount * bizPct;

/// Summary totals for a list of transactions
({double income, double expenses, double net, double businessTotal})
    calculateTransactionSummary(List<Transaction> transactions) {
  double income = 0;
  double expenses = 0;
  double businessTotal = 0;

  for (final t in transactions) {
    if (t.amount >= 0) {
      income += t.amount;
    } else {
      expenses += t.amount.abs();
    }
    businessTotal += calculateBusinessAmount(t.amount.abs(), t.bizPct);
  }

  return (
    income: income,
    expenses: expenses,
    net: income - expenses,
    businessTotal: businessTotal,
  );
}
```

> Note: Income transactions have positive `amount`, expenses are negative. The UI always displays amounts as positive — negate as needed.

Actually — keep it simpler: **all amounts stored as positive**. Income vs expense is determined by category. For v1, all transactions are expenses unless the `category` is "Income". Adjust `calculateTransactionSummary` accordingly:

```dart
bool isIncome(String category) => category == 'Income';

({double income, double expenses, double net, double businessTotal})
    calculateTransactionSummary(List<Transaction> transactions) {
  double income = 0;
  double expenses = 0;
  double businessTotal = 0;

  for (final t in transactions) {
    if (isIncome(t.category)) {
      income += t.amount;
    } else {
      expenses += t.amount;
      businessTotal += calculateBusinessAmount(t.amount, t.bizPct);
    }
  }

  return (
    income: income,
    expenses: expenses,
    net: income - expenses,
    businessTotal: businessTotal,
  );
}
```

---

### Filter Model

File: `lib/features/transactions/models/transaction_filter.dart`

```dart
@freezed
class TransactionFilter with _$TransactionFilter {
  const factory TransactionFilter({
    int? year,
    int? month,       // 1–12, null = all months
    String? category, // null = all categories
    bool? bizOnly,    // true = business only, null = all
  }) = _TransactionFilter;
}
```

---

### Service

File: `lib/features/transactions/data/transaction_service.dart`

```dart
class TransactionService {
  const TransactionService(this._client);
  final SupabaseClient _client;

  Future<List<Transaction>> fetchTransactions(
    String orgId, {
    TransactionFilter filter = const TransactionFilter(),
  }) async { ... }

  Future<void> insertTransaction(Transaction transaction) async { ... }
  Future<void> updateTransaction(Transaction transaction) async { ... }
  Future<void> deleteTransaction(String transactionId) async { ... }
}
```

`fetchTransactions`:
- Always filter by `org_id = orgId`
- If `filter.year` set: filter `date >= YYYY-01-01 AND date <= YYYY-12-31`
- If `filter.month` set (requires year): filter `date >= YYYY-MM-01 AND date <= YYYY-MM-last`
- If `filter.category` set: filter `category = value`
- If `filter.bizOnly` true: filter `biz_pct > 0`
- Order: `date DESC, created_at DESC`

`insertTransaction`: set `created_by` to `client.auth.currentUser!.id`

`updateTransaction`: update by `id`

`deleteTransaction`: delete by `id`

---

### Providers

File: `lib/features/transactions/presentation/providers/transaction_provider.dart`

```dart
@Riverpod(keepAlive: true)
TransactionService transactionService(Ref ref) =>
    TransactionService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<Transaction>> transactions(
  Ref ref,
  String orgId, {
  TransactionFilter filter = const TransactionFilter(),
}) async {
  return ref.read(transactionServiceProvider)
      .fetchTransactions(orgId, filter: filter);
}

@riverpod
class TransactionController extends _$TransactionController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> save(Transaction transaction, {bool isEdit = false}) async { ... }
  Future<void> delete(String transactionId) async { ... }
}
```

Run `build_runner` after.

---

### TASK-008 Acceptance Criteria

- [ ] `Transaction` Freezed model generates cleanly
- [ ] `TransactionFilter` Freezed model generates cleanly
- [ ] All three helpers correct and pure
- [ ] `fetchTransactions` filters correctly for all filter combinations
- [ ] `insertTransaction` / `updateTransaction` / `deleteTransaction` work against live Supabase
- [ ] `build_runner` runs clean
- [ ] `flutter analyze` — zero issues

---

## TASK-010 · Add/Edit Transaction Form

### Overview

Single form widget used for both Add and Edit. On mobile: `showModalBottomSheet`. On desktop: `showDialog` with max width 560px.

File: `lib/features/transactions/presentation/widgets/transaction_form.dart`

Called from:
- Mobile FAB (replace the placeholder in `MobileShell`) → Add mode
- Transaction list item tap → Edit mode
- Desktop "Add Transaction" button → Add mode

---

### Fields

| Field | Widget | Validation |
|---|---|---|
| Date | `TextFormField` + `showDatePicker` | required, defaults to today |
| Amount ($) | `TextFormField` number | required, > 0 |
| Merchant/Payee | `TextFormField` | required |
| Description | `TextFormField` | optional |
| Category | `DropdownButtonFormField` | required — loaded from `categoriesProvider` (unique parent categories) |
| Subcategory | `DropdownButtonFormField` | required — filtered by selected category |
| Business % | `TextFormField` number 0–100 | optional, defaults to 0 (or category default from `budgetDefaultsProvider`) |
| Split Transaction? | `DropdownButtonFormField` Yes/No | defaults to No |
| Notes | `TextFormField` multiline | optional |

**Auto-apply default biz%:** when subcategory is selected, look up matching `BudgetDefault` for that org/category/subcategory and pre-fill the biz% field. Do not overwrite if user has already manually changed it.

**Live split preview:** shown when biz% > 0 in a `greenFill` background box:
```
Personal: $X.XX  |  Business: $X.XX  (Y% business)
```
Updates live as amount or biz% changes.

**Receipt button:** greyed-out `OutlinedButton` with `Icons.attach_file`:
```
📎 Attach Receipt  (Available in a future update)
```
Use `Tooltip` with that message. `onPressed: null`.

**Edit mode:** pre-populate all fields from the existing `Transaction` object passed in.

---

### Form State

Use `ConsumerStatefulWidget` with `TextEditingController` for every text field. Do NOT use autoDispose providers for form field values (learned from auth screens).

---

### On Save

```dart
final transaction = Transaction(
  id: isEdit ? existing.id : const Uuid().v4(),
  orgId: orgId,
  createdBy: client.auth.currentUser!.id,
  date: selectedDate,
  amount: double.parse(amountController.text),
  merchant: merchantController.text.trim(),
  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
  category: selectedCategory!,
  subcategory: selectedSubcategory!,
  bizPct: (double.tryParse(bizPctController.text) ?? 0) / 100,
  isSplit: isSplit,
  receiptId: isEdit ? existing.receiptId : null,
  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
  createdAt: isEdit ? existing.createdAt : DateTime.now(),
);
await ref.read(transactionControllerProvider.notifier).save(transaction, isEdit: isEdit);
```

After save: show `SnackBar` "Transaction saved", close sheet/dialog, invalidate `transactionsProvider`.

**Delete (edit mode only):** confirm `AlertDialog` "Delete this transaction?" → delete → "Transaction deleted" snackbar → pop.

---

### TASK-010 Acceptance Criteria

- [ ] Form opens as bottom sheet on mobile, dialog on desktop
- [ ] All fields present and functional
- [ ] Category dropdown loads from `categoriesProvider`
- [ ] Subcategory filters correctly when category changes
- [ ] Default biz% auto-applies from budget defaults when subcategory selected
- [ ] Live split preview updates correctly
- [ ] Receipt button is visible but disabled with tooltip
- [ ] Edit mode pre-populates all fields
- [ ] Save inserts/updates correctly in Supabase
- [ ] Delete works with confirmation
- [ ] `flutter analyze` — zero issues

---

## TASK-011 · Transactions List Screen

### Layout Router

File: `lib/features/transactions/transactions_screen.dart`

```dart
class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const TransactionsMobileScreen()
        : const TransactionsWebScreen();
  }
}
```

Wire into `app_router.dart` for `/transactions` branch.

Also wire the FAB in `MobileShell` to open `TransactionForm` in add mode (replace the placeholder).

---

### Mobile Layout

File: `lib/features/transactions/layouts/mobile/transactions_mobile_screen.dart`

**Top filters (scrollable rows):**
- Month pills: `All` | `Jan` | `Feb` | ... | `Dec` — teal background when active, border when inactive
- Category chips: `All Categories` | each unique parent category

**Summary row** (between filters and list):
```
N transactions  |  Total: $X  |  Business: $Y  |  Personal: $Z
```
12px muted text, horizontally scrollable if needed.

**Transaction list:**

Each item:
- Left: colored circle icon (green for income, teal for expense, purple if biz% > 0)
- Main: merchant name (bold, 14px) + category/subcategory below (12px muted)
- Right: amount bold (red for expense, green for income) + date below (12px muted)
- Biz badge: small amber chip "BIZ" if `bizPct > 0`
- Tap → opens `TransactionForm` in edit mode

**Empty state:**
```
[icon: receipt_long]
No transactions found
Add your first transaction using the + button
```

---

### Desktop Layout

File: `lib/features/transactions/layouts/web/transactions_web_screen.dart`

**Toolbar row:**
- Search input (left, expands): filters by merchant or description
- Month dropdown: `All Months` | `Jan YYYY` ... `Dec YYYY`
- Category dropdown: `All Categories` | each parent category
- Filter dropdown: `All` | `Personal Only` | `Business Only`
- "Add Transaction" button (teal, right-aligned) → opens `TransactionForm` dialog

**Summary bar** (below toolbar, `tealLight` background):
```
N transactions  |  Income: $X  |  Expenses: $X  |  Net: $X  |  Business: $X
```

**Table:**

Sticky navy header row. Alternating white/lightGray rows.

| Date | Merchant | Description | Amount | Category | Subcategory | Personal | Business | Biz% | Notes | Actions |
|---|---|---|---|---|---|---|---|---|---|---|

- Amount: red for expenses, green for income
- Personal/Business: calculated via helpers
- Biz%: shown as `75%` (multiply stored 0.0–1.0 by 100)
- Actions: `Icons.edit_outlined` (teal) + `Icons.delete_outline` (red)
- Edit icon → opens `TransactionForm` in edit mode
- Delete icon → confirm dialog → delete

**Empty state:** single row spanning all columns, centered text.

---

### Org ID Helper

Both screens need the org ID. Use the same pattern as categories/settings:

```dart
Future<String> _getOrgId(SupabaseClient client) async {
  final userId = client.auth.currentUser!.id;
  final row = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .single();
  return row['org_id'] as String;
}
```

Or better — create a shared `currentOrgIdProvider` in `lib/core/providers/org_provider.dart` that all features can reuse. This avoids repeating the lookup in every feature.

---

## File Map

| File | Task | What |
|---|---|---|
| `lib/features/transactions/models/transaction.dart` | 008 | Freezed model |
| `lib/features/transactions/models/transaction_filter.dart` | 008 | Freezed filter model |
| `lib/features/transactions/helpers/transaction_calculations.dart` | 008 | Pure helpers |
| `lib/features/transactions/data/transaction_service.dart` | 008 | Supabase CRUD |
| `lib/features/transactions/presentation/providers/transaction_provider.dart` | 008 | Riverpod providers |
| `lib/features/transactions/presentation/widgets/transaction_form.dart` | 010 | Add/Edit form widget |
| `lib/features/transactions/transactions_screen.dart` | 011 | Layout router |
| `lib/features/transactions/layouts/mobile/transactions_mobile_screen.dart` | 011 | Mobile list |
| `lib/features/transactions/layouts/web/transactions_web_screen.dart` | 011 | Desktop table |
| `lib/core/providers/org_provider.dart` | 008 | Shared `currentOrgIdProvider` |
| `lib/core/routing/app_router.dart` | 011 | Wire `/transactions` + update FAB |

---

## Key Rules

- `build_runner` after all `@riverpod` and `@freezed` changes
- Org scope on every Supabase query
- All amounts stored as positive — use `isIncome(category)` to determine sign
- `bizPct` stored as 0.0–1.0; UI shows/inputs 0–100 — convert on read/write
- `TextEditingController` for all form fields — no autoDispose providers for text state
- Capture `GoRouter`/`ScaffoldMessenger` before any `await`
- `uuid` package already in pubspec — use for client-generated IDs
