// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'created_by') required String createdBy,
    required DateTime date,
    required double amount,
    required String merchant,
    String? description,
    required String category,
    required String subcategory,
    @JsonKey(name: 'biz_pct') required double bizPct,
    @JsonKey(name: 'is_split') required bool isSplit,
    @JsonKey(name: 'receipt_id') String? receiptId,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
