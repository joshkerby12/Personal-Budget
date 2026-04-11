import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/pantry_deal_service.dart';
import '../../data/pantry_item_service.dart';
import '../../data/pantry_meal_plan_service.dart';
import '../../data/pantry_meal_service.dart';
import '../../data/pantry_stocked_service.dart';
import '../../data/pantry_store_service.dart';
import '../../models/pantry_deal.dart';
import '../../models/pantry_item.dart';
import '../../models/pantry_meal.dart';
import '../../models/pantry_meal_plan_entry.dart';
import '../../models/pantry_stocked_item.dart';
import '../../models/pantry_store.dart';

part 'pantry_providers.g.dart';

// Realtime note:
// Supabase replication must be enabled for:
// pantry_stores, pantry_items, pantry_stocked, pantry_meals, pantry_meal_plan.

@Riverpod(keepAlive: true)
PantryStoreService pantryStoreService(Ref ref) {
  return PantryStoreService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
PantryItemService pantryItemService(Ref ref) {
  return PantryItemService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
PantryStockedService pantryStockedService(Ref ref) {
  return PantryStockedService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
PantryMealService pantryMealService(Ref ref) {
  return PantryMealService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
PantryMealPlanService pantryMealPlanService(Ref ref) {
  return PantryMealPlanService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
PantryDealService pantryDealService(Ref ref) {
  return PantryDealService(ref.watch(supabaseClientProvider));
}

@riverpod
Stream<List<PantryStore>> pantryStores(Ref ref, String orgId) {
  return ref
      .watch(supabaseClientProvider)
      .from('pantry_stores')
      .stream(primaryKey: <String>['id'])
      .eq('org_id', orgId)
      .map((List<Map<String, dynamic>> rows) {
        final List<PantryStore> stores = rows
            .map(PantryStore.fromJson)
            .toList(growable: false);
        stores.sort((PantryStore a, PantryStore b) {
          final int sortOrderCompare = a.sortOrder.compareTo(b.sortOrder);
          if (sortOrderCompare != 0) {
            return sortOrderCompare;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
        return stores;
      });
}

@riverpod
Stream<List<PantryItem>> pantryItems(Ref ref, String orgId, String storeId) {
  return ref
      .watch(supabaseClientProvider)
      .from('pantry_items')
      .stream(primaryKey: <String>['id'])
      .eq('org_id', orgId)
      .map((List<Map<String, dynamic>> rows) {
        final List<PantryItem> items = rows
            .map(PantryItem.fromJson)
            .where((PantryItem item) => item.storeId == storeId)
            .toList(growable: false);
        items.sort((PantryItem a, PantryItem b) {
          final int checkedCompare = a.checked == b.checked
              ? 0
              : (a.checked ? 1 : -1);
          if (checkedCompare != 0) {
            return checkedCompare;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
        return items;
      });
}

@riverpod
Stream<List<PantryStockedItem>> pantryStocked(Ref ref, String orgId) {
  return ref
      .watch(supabaseClientProvider)
      .from('pantry_stocked')
      .stream(primaryKey: <String>['id'])
      .eq('org_id', orgId)
      .map((List<Map<String, dynamic>> rows) {
        final List<PantryStockedItem> stocked = rows
            .map(PantryStockedItem.fromJson)
            .toList(growable: false);
        stocked.sort((PantryStockedItem a, PantryStockedItem b) {
          return a.name.compareTo(b.name);
        });
        return stocked;
      });
}

@riverpod
Stream<List<PantryMeal>> pantryMeals(Ref ref, String orgId) {
  return ref
      .watch(supabaseClientProvider)
      .from('pantry_meals')
      .stream(primaryKey: <String>['id'])
      .eq('org_id', orgId)
      .map((List<Map<String, dynamic>> rows) {
        final List<PantryMeal> meals = rows
            .map(PantryMeal.fromJson)
            .toList(growable: false);
        meals.sort((PantryMeal a, PantryMeal b) {
          return b.createdAt.compareTo(a.createdAt);
        });
        return meals;
      });
}

@riverpod
Stream<List<PantryMealPlanEntry>> pantryMealPlan(
  Ref ref,
  String orgId,
  DateTime weekStart,
) {
  final DateTime normalizedWeekStart = DateTime(
    weekStart.year,
    weekStart.month,
    weekStart.day,
  );
  final DateTime weekEnd = normalizedWeekStart.add(const Duration(days: 7));

  return ref
      .watch(supabaseClientProvider)
      .from('pantry_meal_plan')
      .stream(primaryKey: <String>['id'])
      .eq('org_id', orgId)
      .map((List<Map<String, dynamic>> rows) {
        final List<PantryMealPlanEntry> entries = rows
            .map(PantryMealPlanEntry.fromJson)
            .where((PantryMealPlanEntry entry) {
              final DateTime planDate = DateTime(
                entry.planDate.year,
                entry.planDate.month,
                entry.planDate.day,
              );
              return !planDate.isBefore(normalizedWeekStart) &&
                  planDate.isBefore(weekEnd);
            })
            .toList(growable: false);
        entries.sort((PantryMealPlanEntry a, PantryMealPlanEntry b) {
          final int dateCompare = a.planDate.compareTo(b.planDate);
          if (dateCompare != 0) {
            return dateCompare;
          }
          final int slotCompare = _mealSlotOrderIndex(
            a.mealSlot,
          ).compareTo(_mealSlotOrderIndex(b.mealSlot));
          if (slotCompare != 0) {
            return slotCompare;
          }
          return a.createdAt.compareTo(b.createdAt);
        });
        return entries;
      });
}

@riverpod
Future<List<PantryDeal>> pantryDeals(Ref ref, String orgId) async {
  return ref.read(pantryDealServiceProvider).fetchDeals(orgId);
}

int _mealSlotOrderIndex(String slot) {
  switch (slot.trim().toLowerCase()) {
    case 'breakfast':
      return 0;
    case 'lunch':
      return 1;
    case 'dinner':
      return 2;
    default:
      return 99;
  }
}
