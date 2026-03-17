import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt_filter.freezed.dart';

@freezed
abstract class ReceiptFilter with _$ReceiptFilter {
  const factory ReceiptFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? searchText,
    bool? linkedOnly,
    bool? unlinkedOnly,
  }) = _ReceiptFilter;
}
