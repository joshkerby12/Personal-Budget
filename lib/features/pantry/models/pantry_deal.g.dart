// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_deal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryDeal _$PantryDealFromJson(Map<String, dynamic> json) => _PantryDeal(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  storeName: json['store_name'] as String,
  itemName: json['item_name'] as String,
  category: json['category'] as String,
  salePrice: (json['sale_price'] as num).toDouble(),
  originalPrice: (json['original_price'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PantryDealToJson(_PantryDeal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'store_name': instance.storeName,
      'item_name': instance.itemName,
      'category': instance.category,
      'sale_price': instance.salePrice,
      'original_price': instance.originalPrice,
      'unit': instance.unit,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
