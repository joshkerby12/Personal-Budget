// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryItem _$PantryItemFromJson(Map<String, dynamic> json) => _PantryItem(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  storeId: json['store_id'] as String,
  name: json['name'] as String,
  qty: (json['qty'] as num).toDouble(),
  unit: json['unit'] as String?,
  category: json['category'] as String,
  checked: json['checked'] as bool,
  isStocked: json['is_stocked'] as bool,
  price: (json['price'] as num?)?.toDouble(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PantryItemToJson(_PantryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'store_id': instance.storeId,
      'name': instance.name,
      'qty': instance.qty,
      'unit': instance.unit,
      'category': instance.category,
      'checked': instance.checked,
      'is_stocked': instance.isStocked,
      'price': instance.price,
      'created_at': instance.createdAt.toIso8601String(),
    };
