// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_default.freezed.dart';
part 'budget_default.g.dart';

@freezed
abstract class BudgetDefault with _$BudgetDefault {
  const factory BudgetDefault({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    required String category,
    required String subcategory,
    @JsonKey(name: 'monthly_amount') required double monthlyAmount,
    @JsonKey(name: 'default_biz_pct') required double defaultBizPct,
    DateTime? month,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _BudgetDefault;

  factory BudgetDefault.fromJson(Map<String, dynamic> json) =>
      _$BudgetDefaultFromJson(json);
}
