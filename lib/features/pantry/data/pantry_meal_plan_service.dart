import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_meal_plan_entry.dart';

class PantryMealPlanService {
  const PantryMealPlanService(this._client);

  final SupabaseClient _client;

  Future<List<PantryMealPlanEntry>> fetchPlanForWeek(
    String orgId,
    DateTime weekStart,
  ) async {
    final DateTime normalizedWeekStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final DateTime weekEnd = normalizedWeekStart.add(const Duration(days: 7));

    final List<dynamic> rows = await _client
        .from('pantry_meal_plan')
        .select()
        .eq('org_id', orgId)
        .gte('plan_date', _dateOnly(normalizedWeekStart))
        .lt('plan_date', _dateOnly(weekEnd))
        .order('plan_date', ascending: true)
        .order('created_at', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(PantryMealPlanEntry.fromJson)
        .toList(growable: false);
  }

  Future<PantryMealPlanEntry> addToPlan(
    String orgId,
    String mealId,
    DateTime date, {
    String mealSlot = 'dinner',
  }) async {
    final Map<String, dynamic> row = await _client
        .from('pantry_meal_plan')
        .insert(<String, dynamic>{
          'org_id': orgId,
          'meal_id': mealId,
          'plan_date': _dateOnly(date),
          'meal_slot': mealSlot,
        })
        .select()
        .single();

    return PantryMealPlanEntry.fromJson(row);
  }

  Future<void> removeFromPlan(String entryId) async {
    await _client.from('pantry_meal_plan').delete().eq('id', entryId);
  }
}

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
