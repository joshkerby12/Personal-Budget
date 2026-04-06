import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pantry_meal.dart';

class PantryMealService {
  const PantryMealService(this._client);

  final SupabaseClient _client;

  Future<List<PantryMeal>> fetchMeals(String orgId) async {
    final List<dynamic> rows = await _client
        .from('pantry_meals')
        .select()
        .eq('org_id', orgId)
        .order('created_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(PantryMeal.fromJson)
        .toList(growable: false);
  }

  Future<PantryMeal> createMeal({
    required String orgId,
    required String name,
    required List<String> ingredients,
    double? costPerServing,
    int servings = 1,
    String source = 'manual',
    String? url,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Meal name cannot be empty.');
    }

    final List<String> cleanIngredients = ingredients
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    final Map<String, dynamic> row = await _client
        .from('pantry_meals')
        .insert(<String, dynamic>{
          'org_id': orgId,
          'name': trimmedName,
          'ingredients': cleanIngredients,
          'cost_per_serving': costPerServing,
          'servings': servings,
          'source': source,
          'url': url?.trim().isEmpty == true ? null : url?.trim(),
        })
        .select()
        .single();

    return PantryMeal.fromJson(row);
  }

  Future<void> updateMeal(PantryMeal meal) async {
    await _client
        .from('pantry_meals')
        .update(<String, dynamic>{
          'name': meal.name.trim(),
          'ingredients': meal.ingredients
              .map((String value) => value.trim())
              .where((String value) => value.isNotEmpty)
              .toList(growable: false),
          'cost_per_serving': meal.costPerServing,
          'servings': meal.servings,
          'source': meal.source,
          'url': meal.url?.trim().isEmpty == true ? null : meal.url?.trim(),
        })
        .eq('id', meal.id);
  }

  Future<void> deleteMeal(String mealId) async {
    await _client.from('pantry_meals').delete().eq('id', mealId);
  }
}
