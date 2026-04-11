import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/csv_import_service.dart';
import '../../data/transaction_service.dart';
import '../../helpers/csv_institution_maps.dart';
import '../../helpers/csv_parser.dart';
import '../../models/csv_import_log.dart';
import '../../models/transaction.dart';
import '../../models/transaction_filter.dart';
import '../../models/transaction_split.dart';

part 'transaction_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionService transactionService(Ref ref) {
  return TransactionService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
CsvImportService csvImportService(Ref ref) {
  return CsvImportService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<Transaction>> transactions(
  Ref ref,
  String orgId, {
  TransactionFilter filter = const TransactionFilter(),
}) async {
  return ref
      .read(transactionServiceProvider)
      .fetchTransactions(orgId, filter: filter);
}

@riverpod
Future<List<Transaction>> recentCategorizedTransactions(
  Ref ref,
  String orgId,
) async {
  final DateTime cutoff = DateTime.now().toUtc().subtract(
    const Duration(days: 90),
  );
  final String cutoffDate = _dateOnly(cutoff);

  final List<dynamic> rows = await ref
      .read(supabaseClientProvider)
      .from('transactions')
      .select()
      .eq('org_id', orgId)
      .gte('date', cutoffDate)
      .neq('category', 'Uncategorized')
      .order('date', ascending: false)
      .order('created_at', ascending: false);

  return rows
      .cast<Map<String, dynamic>>()
      .map(Transaction.fromJson)
      .toList(growable: false);
}

@riverpod
Future<List<CsvImportLog>> csvImportLogs(Ref ref, String orgId) async {
  return ref.read(csvImportServiceProvider).fetchImportLogs(orgId);
}

@riverpod
Future<List<TransactionSplit>> transactionSplits(
  Ref ref,
  String transactionId,
) async {
  return ref
      .read(transactionServiceProvider)
      .fetchSplitsForTransaction(transactionId);
}

@riverpod
class TransactionController extends _$TransactionController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> save(
    Transaction transaction, {
    bool isEdit = false,
    List<TransactionSplit>? splits,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      if (isEdit) {
        await ref
            .read(transactionServiceProvider)
            .updateTransaction(transaction, splits: splits);
      } else {
        await ref
            .read(transactionServiceProvider)
            .insertTransaction(transaction, splits: splits);
      }

      ref.invalidate(transactionsProvider(transaction.orgId));
      ref.invalidate(transactionSplitsProvider(transaction.id));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> delete(String transactionId, String orgId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionServiceProvider)
          .deleteTransaction(transactionId);
      ref.invalidate(transactionsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

@riverpod
class CsvImportController extends _$CsvImportController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<CsvImportLog> runImport({
    required CsvInstitution institution,
    required String filename,
    required String rawCsv,
    required String orgId,
    required String createdBy,
  }) async {
    final CsvColumnMap? columnMap = kCsvInstitutionMaps[institution];
    if (columnMap == null) {
      throw StateError('No CSV mapping configured for ${institution.label}.');
    }

    state = const AsyncLoading<void>();
    try {
      final List<CsvRow> rows = parseCsv(rawCsv, columnMap);
      final CsvImportLog log = await ref
          .read(csvImportServiceProvider)
          .importCsv(
            orgId: orgId,
            createdBy: createdBy,
            institution: institution,
            filename: filename,
            rows: rows,
          );

      ref.invalidate(transactionsProvider(orgId));
      ref.invalidate(csvImportLogsProvider(orgId));
      state = const AsyncData<void>(null);
      return log;
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      rethrow;
    }
  }
}

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
