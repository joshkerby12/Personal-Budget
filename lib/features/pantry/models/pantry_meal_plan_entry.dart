// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_meal_plan_entry.freezed.dart';
part 'pantry_meal_plan_entry.g.dart';

@freezed
abstract class PantryMealPlanEntry with _$PantryMealPlanEntry {
  const factory PantryMealPlanEntry({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'meal_id') required String mealId,
    @JsonKey(name: 'plan_date') required DateTime planDate,
    @JsonKey(name: 'meal_slot') required String mealSlot,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _PantryMealPlanEntry;

  factory PantryMealPlanEntry.fromJson(Map<String, dynamic> json) =>
      _$PantryMealPlanEntryFromJson(json);
}
