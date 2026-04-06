// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_meal_plan_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryMealPlanEntry _$PantryMealPlanEntryFromJson(Map<String, dynamic> json) =>
    _PantryMealPlanEntry(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      mealId: json['meal_id'] as String,
      planDate: DateTime.parse(json['plan_date'] as String),
      mealSlot: json['meal_slot'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PantryMealPlanEntryToJson(
  _PantryMealPlanEntry instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'meal_id': instance.mealId,
  'plan_date': instance.planDate.toIso8601String(),
  'meal_slot': instance.mealSlot,
  'created_at': instance.createdAt.toIso8601String(),
};
