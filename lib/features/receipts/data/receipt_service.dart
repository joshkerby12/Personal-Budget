import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/receipt.dart';
import '../models/receipt_filter.dart';

const int _maxReceiptBytes = 10 * 1024 * 1024;

class ReceiptService {
  const ReceiptService(this._client);

  final SupabaseClient _client;

  Future<List<Receipt>> fetchReceipts(
    String orgId, {
    ReceiptFilter filter = const ReceiptFilter(),
  }) async {
    dynamic query = _client.from('receipts').select().eq('org_id', orgId);

    if (filter.startDate != null) {
      query = query.gte(
        'created_at',
        filter.startDate!.toUtc().toIso8601String(),
      );
    }

    if (filter.endDate != null) {
      final DateTime end = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
        999,
      );
      query = query.lte('created_at', end.toUtc().toIso8601String());
    }

    final String? search = filter.searchText?.trim();
    if (search != null && search.isNotEmpty) {
      query = query.ilike('filename', '%$search%');
    }

    if (filter.linkedOnly == true) {
      query = query.not('transaction_id', 'is', null);
    } else if (filter.unlinkedOnly == true) {
      query = query.isFilter('transaction_id', null);
    }

    final List<dynamic> rows = await query.order(
      'created_at',
      ascending: false,
    );
    return rows
        .cast<Map<String, dynamic>>()
        .map(Receipt.fromJson)
        .toList(growable: false);
  }

  Future<Receipt> uploadReceipt(
    String orgId,
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    if (bytes.length > _maxReceiptBytes) {
      throw StateError('File is too large. Maximum size is 10MB.');
    }

    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to upload a receipt.');
    }

    final String receiptId = const Uuid().v4();
    final DateTime now = DateTime.now();
    final String normalizedName = filename.replaceAll(RegExp(r'[\\/]'), '_');
    final String storagePath =
        '$orgId/${now.year}/${now.month.toString().padLeft(2, '0')}/${receiptId}_$normalizedName';

    await _client.storage
        .from('receipts')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );

    try {
      final Map<String, dynamic> row = await _client
          .from('receipts')
          .insert(<String, dynamic>{
            'id': receiptId,
            'org_id': orgId,
            'transaction_id': null,
            'filename': normalizedName,
            'storage_path': storagePath,
            'mime_type': mimeType,
            'size_bytes': bytes.length,
            'uploaded_by': userId,
          })
          .select()
          .single();

      return Receipt.fromJson(row);
    } catch (_) {
      await _client.storage.from('receipts').remove(<String>[storagePath]);
      rethrow;
    }
  }

  Future<void> linkReceiptToTransaction(
    String receiptId,
    String transactionId,
  ) async {
    await _client
        .from('receipts')
        .update(<String, dynamic>{'transaction_id': transactionId})
        .eq('id', receiptId);
  }

  Future<void> unlinkReceipt(String receiptId) async {
    await _client
        .from('receipts')
        .update(<String, dynamic>{'transaction_id': null})
        .eq('id', receiptId);
  }

  Future<void> deleteReceipt(String receiptId, String storagePath) async {
    await _client.storage.from('receipts').remove(<String>[storagePath]);
    await _client.from('receipts').delete().eq('id', receiptId);
  }

  Future<String> getDownloadUrl(String storagePath) async {
    return _client.storage.from('receipts').createSignedUrl(storagePath, 3600);
  }
}
