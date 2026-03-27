// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  createdBy: json['created_by'] as String,
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num).toDouble(),
  merchant: json['merchant'] as String,
  description: json['description'] as String?,
  category: json['category'] as String,
  subcategory: json['subcategory'] as String,
  bizPct: (json['biz_pct'] as num).toDouble(),
  isSplit: json['is_split'] as bool,
  receiptId: json['receipt_id'] as String?,
  notes: json['notes'] as String?,
  noMiles: json['no_miles'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'created_by': instance.createdBy,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'merchant': instance.merchant,
      'description': instance.description,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'biz_pct': instance.bizPct,
      'is_split': instance.isSplit,
      'receipt_id': instance.receiptId,
      'notes': instance.notes,
      'no_miles': instance.noMiles,
      'created_at': instance.createdAt.toIso8601String(),
    };
