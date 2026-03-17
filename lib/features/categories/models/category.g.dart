// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  parentCategory: json['parent_category'] as String,
  subcategory: json['subcategory'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'parent_category': instance.parentCategory,
  'subcategory': instance.subcategory,
  'sort_order': instance.sortOrder,
};
