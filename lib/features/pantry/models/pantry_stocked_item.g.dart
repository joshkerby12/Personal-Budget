// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_stocked_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryStockedItem _$PantryStockedItemFromJson(Map<String, dynamic> json) =>
    _PantryStockedItem(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PantryStockedItemToJson(_PantryStockedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'name': instance.name,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
