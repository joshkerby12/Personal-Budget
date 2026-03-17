import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_filter.freezed.dart';

@freezed
abstract class TransactionFilter with _$TransactionFilter {
  const factory TransactionFilter({
    int? year,
    int? month,
    String? category,
    bool? bizOnly,
  }) = _TransactionFilter;
}
