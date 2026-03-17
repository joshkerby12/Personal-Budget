// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'receipt.freezed.dart';
part 'receipt.g.dart';

@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'transaction_id') String? transactionId,
    required String filename,
    @JsonKey(name: 'storage_path') required String storagePath,
    @JsonKey(name: 'mime_type') required String mimeType,
    @JsonKey(name: 'size_bytes') required int sizeBytes,
    @JsonKey(name: 'uploaded_by') required String uploadedBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) =>
      _$ReceiptFromJson(json);
}
