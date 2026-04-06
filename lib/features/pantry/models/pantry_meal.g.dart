// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryMeal _$PantryMealFromJson(Map<String, dynamic> json) => _PantryMeal(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  name: json['name'] as String,
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  costPerServing: (json['cost_per_serving'] as num?)?.toDouble(),
  servings: (json['servings'] as num).toInt(),
  source: json['source'] as String,
  url: json['url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PantryMealToJson(_PantryMeal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'name': instance.name,
      'ingredients': instance.ingredients,
      'cost_per_serving': instance.costPerServing,
      'servings': instance.servings,
      'source': instance.source,
      'url': instance.url,
      'created_at': instance.createdAt.toIso8601String(),
    };
