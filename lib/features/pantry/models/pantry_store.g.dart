// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryStore _$PantryStoreFromJson(Map<String, dynamic> json) => _PantryStore(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PantryStoreToJson(_PantryStore instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'name': instance.name,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
    };
