import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/receipt_service.dart';
import '../../models/receipt.dart';
import '../../models/receipt_filter.dart';

part 'receipt_provider.g.dart';

@Riverpod(keepAlive: true)
ReceiptService receiptService(Ref ref) {
  return ReceiptService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<String?> receiptsOrgId(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null) {
    return null;
  }

  final Map<String, dynamic>? member = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  return member?['org_id'] as String?;
}

@riverpod
Future<List<Receipt>> receipts(
  Ref ref,
  String orgId, {
  ReceiptFilter filter = const ReceiptFilter(),
}) async {
  return ref.read(receiptServiceProvider).fetchReceipts(orgId, filter: filter);
}

@riverpod
class ReceiptController extends _$ReceiptController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<Receipt?> pickAndUpload(String orgId) async {
    state = const AsyncLoading<void>();
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        state = const AsyncData<void>(null);
        return null;
      }

      final PlatformFile file = result.files.single;
      final String? filename = file.name.trim().isEmpty ? null : file.name;
      final bytes = file.bytes;
      if (filename == null || bytes == null) {
        throw StateError('Unable to read the selected file.');
      }

      final String mimeType =
          lookupMimeType(filename) ?? 'application/octet-stream';
      final Receipt receipt = await ref
          .read(receiptServiceProvider)
          .uploadReceipt(orgId, bytes, filename, mimeType);
      ref.invalidate(receiptsProvider);
      state = const AsyncData<void>(null);
      return receipt;
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      rethrow;
    }
  }

  Future<void> linkToTransaction(String receiptId, String transactionId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref
          .read(receiptServiceProvider)
          .linkReceiptToTransaction(receiptId, transactionId);
      ref.invalidate(receiptsProvider);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> unlink(String receiptId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref.read(receiptServiceProvider).unlinkReceipt(receiptId);
      ref.invalidate(receiptsProvider);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> delete(String receiptId, String storagePath) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref
          .read(receiptServiceProvider)
          .deleteReceipt(receiptId, storagePath);
      ref.invalidate(receiptsProvider);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}
