// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_default.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetDefault _$BudgetDefaultFromJson(Map<String, dynamic> json) =>
    _BudgetDefault(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      monthlyAmount: (json['monthly_amount'] as num).toDouble(),
      defaultBizPct: (json['default_biz_pct'] as num).toDouble(),
      month: json['month'] == null
          ? null
          : DateTime.parse(json['month'] as String),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BudgetDefaultToJson(_BudgetDefault instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'monthly_amount': instance.monthlyAmount,
      'default_biz_pct': instance.defaultBizPct,
      'month': instance.month?.toIso8601String(),
      'sort_order': instance.sortOrder,
    };
