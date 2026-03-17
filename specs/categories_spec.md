# Categories Spec — TASK-006

Category data layer. No UI in this task — pure data: model, service, provider, and default seed.

---

## Overview

Categories are org-scoped. Every transaction is tagged with a `parentCategory` + `subcategory` pair. A default set is seeded when a new org is created. Users can add/rename/delete subcategories later (TASK-007).

---

## Data Model

### `Category` (Freezed)

File: `lib/features/categories/models/category.dart`

```dart
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String orgId,
    required String parentCategory,
    required String subcategory,
    required int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
```

JSON key mapping (snake_case from Supabase → camelCase in Dart):
- `org_id` → `orgId`
- `parent_category` → `parentCategory`
- `sort_order` → `sortOrder`

---

## Service

File: `lib/features/categories/data/category_service.dart`

```dart
class CategoryService {
  const CategoryService(this._client);
  final SupabaseClient _client;

  Future<List<Category>> fetchCategories(String orgId) async { ... }
  Future<void> seedDefaultCategories(String orgId) async { ... }
}
```

### `fetchCategories(orgId)`
- Query `categories` table where `org_id = orgId`
- Order by `sort_order ASC`
- Return `List<Category>`

### `seedDefaultCategories(orgId)`
- Insert all rows from the default seed list below with the given `orgId`
- Use `upsert` with `onConflict: 'org_id,parent_category,subcategory'` so re-running is safe
- Called from `OnboardingController` after org is created (update `OrgService.createOrg` or call from `OnboardingController` after org creation — either is fine)

---

## Provider

File: `lib/features/categories/presentation/providers/categories_provider.dart`

```dart
@riverpod
Future<List<Category>> categories(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  // fetch org_id for current user from org_members
  final member = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId!)
      .single();
  final orgId = member['org_id'] as String;
  return ref.read(categoryServiceProvider).fetchCategories(orgId);
}

@riverpod
CategoryService categoryService(Ref ref) {
  return CategoryService(ref.watch(supabaseClientProvider));
}
```

Run `build_runner` after creating this file.

---

## Default Category Seed

Seed these rows on new org creation. `sort_order` increments by 10 within each parent group (leaves room to insert between).

| parentCategory | subcategory | sortOrder |
|---|---|---|
| Housing | Mortgage/Rent | 10 |
| Housing | Property Tax | 20 |
| Housing | HOA Fees | 30 |
| Housing | Home Insurance | 40 |
| Housing | Home Maintenance | 50 |
| Housing | Utilities - Electric | 60 |
| Housing | Utilities - Gas | 70 |
| Housing | Utilities - Water | 80 |
| Housing | Internet | 90 |
| Housing | Phone | 100 |
| Transportation | Car Payment | 10 |
| Transportation | Car Insurance | 20 |
| Transportation | Gas/Fuel | 30 |
| Transportation | Car Maintenance | 40 |
| Transportation | Parking/Tolls | 50 |
| Transportation | Public Transit | 60 |
| Food | Groceries | 10 |
| Food | Dining Out | 20 |
| Food | Coffee/Drinks | 30 |
| Food | Takeout/Delivery | 40 |
| Healthcare | Health Insurance | 10 |
| Healthcare | Doctor/Dentist | 20 |
| Healthcare | Prescriptions | 30 |
| Healthcare | Vision | 40 |
| Healthcare | Gym/Fitness | 50 |
| Personal | Clothing | 10 |
| Personal | Hair/Beauty | 20 |
| Personal | Personal Care | 30 |
| Personal | Subscriptions | 40 |
| Personal | Entertainment | 50 |
| Personal | Hobbies | 60 |
| Children | Childcare/Daycare | 10 |
| Children | School/Tuition | 20 |
| Children | School Supplies | 30 |
| Children | Activities/Sports | 40 |
| Children | Toys/Clothing | 50 |
| Savings | Emergency Fund | 10 |
| Savings | Retirement | 20 |
| Savings | Investments | 30 |
| Savings | Vacation Fund | 40 |
| Business | Office Supplies | 10 |
| Business | Software/Tools | 20 |
| Business | Marketing | 30 |
| Business | Professional Services | 40 |
| Business | Travel | 50 |
| Business | Meals (Business) | 60 |
| Business | Equipment | 70 |
| Business | Other Business | 80 |
| Debt | Credit Card | 10 |
| Debt | Student Loan | 20 |
| Debt | Personal Loan | 30 |
| Debt | Other Debt | 40 |
| Giving | Charitable Donations | 10 |
| Giving | Church/Tithe | 20 |
| Giving | Gifts | 30 |
| Income | Salary/Wages | 10 |
| Income | Freelance/Side Income | 20 |
| Income | Rental Income | 30 |
| Income | Investment Income | 40 |
| Income | Other Income | 50 |
| Other | Miscellaneous | 10 |

---

## Acceptance Criteria

- [ ] `Category` Freezed model generates cleanly with `build_runner`
- [ ] `categoryServiceProvider` and `categoriesProvider` exist and compile
- [ ] `fetchCategories` returns rows ordered by `sort_order`
- [ ] `seedDefaultCategories` inserts all rows above for a given `orgId`
- [ ] Seeding is idempotent — calling it twice does not create duplicates
- [ ] `flutter analyze` — zero issues

---

## Key Rules

- No UI in this task
- `build_runner` after all `@riverpod` and `@freezed` changes
- Org scope on every query — no query without `org_id` filter
- Use `upsert` not `insert` for seed so it's safe to re-run
