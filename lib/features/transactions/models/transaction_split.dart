// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_split.freezed.dart';
part 'transaction_split.g.dart';

@freezed
abstract class TransactionSplit with _$TransactionSplit {
  const factory TransactionSplit({
    required String id,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'org_id') required String orgId,
    required String category,
    required String subcategory,
    required double amount,
    @JsonKey(name: 'biz_pct') @Default(0.0) double bizPct,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TransactionSplit;

  factory TransactionSplit.fromJson(Map<String, dynamic> json) =>
      _$TransactionSplitFromJson(json);
}
