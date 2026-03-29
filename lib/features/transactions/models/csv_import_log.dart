// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'csv_import_log.freezed.dart';
part 'csv_import_log.g.dart';

@freezed
abstract class CsvImportLog with _$CsvImportLog {
  const factory CsvImportLog({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String institution,
    required String filename,
    @JsonKey(name: 'imported_at') required DateTime importedAt,
    @JsonKey(name: 'transaction_count') required int transactionCount,
  }) = _CsvImportLog;

  factory CsvImportLog.fromJson(Map<String, dynamic> json) =>
      _$CsvImportLogFromJson(json);
}
