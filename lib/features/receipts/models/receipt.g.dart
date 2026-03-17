// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Receipt _$ReceiptFromJson(Map<String, dynamic> json) => _Receipt(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  transactionId: json['transaction_id'] as String?,
  filename: json['filename'] as String,
  storagePath: json['storage_path'] as String,
  mimeType: json['mime_type'] as String,
  sizeBytes: (json['size_bytes'] as num).toInt(),
  uploadedBy: json['uploaded_by'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReceiptToJson(_Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'transaction_id': instance.transactionId,
  'filename': instance.filename,
  'storage_path': instance.storagePath,
  'mime_type': instance.mimeType,
  'size_bytes': instance.sizeBytes,
  'uploaded_by': instance.uploadedBy,
  'created_at': instance.createdAt.toIso8601String(),
};
