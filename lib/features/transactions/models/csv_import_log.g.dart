// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csv_import_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CsvImportLog _$CsvImportLogFromJson(Map<String, dynamic> json) =>
    _CsvImportLog(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      createdBy: json['created_by'] as String,
      institution: json['institution'] as String,
      filename: json['filename'] as String,
      importedAt: DateTime.parse(json['imported_at'] as String),
      transactionCount: (json['transaction_count'] as num).toInt(),
    );

Map<String, dynamic> _$CsvImportLogToJson(_CsvImportLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'created_by': instance.createdBy,
      'institution': instance.institution,
      'filename': instance.filename,
      'imported_at': instance.importedAt.toIso8601String(),
      'transaction_count': instance.transactionCount,
    };
