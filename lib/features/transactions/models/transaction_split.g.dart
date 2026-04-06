// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_split.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionSplit _$TransactionSplitFromJson(Map<String, dynamic> json) =>
    _TransactionSplit(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      orgId: json['org_id'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      amount: (json['amount'] as num).toDouble(),
      bizPct: (json['biz_pct'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TransactionSplitToJson(_TransactionSplit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_id': instance.transactionId,
      'org_id': instance.orgId,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'amount': instance.amount,
      'biz_pct': instance.bizPct,
      'created_at': instance.createdAt.toIso8601String(),
    };
