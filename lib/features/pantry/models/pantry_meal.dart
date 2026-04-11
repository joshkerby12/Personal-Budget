// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_meal.freezed.dart';
part 'pantry_meal.g.dart';

@freezed
abstract class PantryMeal with _$PantryMeal {
  const factory PantryMeal({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    required String name,
    required List<String> ingredients,
    @JsonKey(name: 'cost_per_serving') double? costPerServing,
    required int servings,
    required String source,
    String? url,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PantryMeal;

  factory PantryMeal.fromJson(Map<String, dynamic> json) =>
      _$PantryMealFromJson(json);
}
