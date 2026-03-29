import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../helpers/csv_dedup.dart';
import '../helpers/csv_institution_maps.dart';
import '../helpers/csv_parser.dart';
import '../models/csv_import_log.dart';
import '../models/transaction.dart';

class CsvImportService {
  CsvImportService(this._client);

  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  Future<List<CsvImportLog>> fetchImportLogs(String orgId) async {
    final List<dynamic> rows = await _client
        .from('csv_import_logs')
        .select()
        .eq('org_id', orgId)
        .order('imported_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(CsvImportLog.fromJson)
        .toList(growable: false);
  }

  Future<List<Transaction>> fetchTransactionsForImport(
    String importLogId,
  ) async {
    final List<dynamic> links = await _client
        .from('csv_import_transactions')
        .select('transaction_id')
        .eq('import_log_id', importLogId);

    final List<String> transactionIds = links
        .cast<Map<String, dynamic>>()
        .map((Map<String, dynamic> row) => row['transaction_id'] as String?)
        .whereType<String>()
        .toList(growable: false);

    if (transactionIds.isEmpty) {
      return const <Transaction>[];
    }

    final List<dynamic> rows = await _client
        .from('transactions')
        .select()
        .inFilter('id', transactionIds)
        .order('date', ascending: false)
        .order('created_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(Transaction.fromJson)
        .toList(growable: false);
  }

  Future<CsvImportLog> importCsv({
    required String orgId,
    required String createdBy,
    required CsvInstitution institution,
    required String filename,
    required List<CsvRow> rows,
  }) async {
    final DateTime cutoff = DateTime.now().toUtc().subtract(
      const Duration(days: 183),
    );

    final List<dynamic> existingRows = await _client
        .from('transactions')
        .select()
        .eq('org_id', orgId)
        .gte('date', _dateOnly(cutoff))
        .order('date', ascending: false)
        .order('created_at', ascending: false);

    final List<Transaction> existingTransactions = existingRows
        .cast<Map<String, dynamic>>()
        .map(Transaction.fromJson)
        .toList(growable: false);

    final List<CsvRow> deduplicatedRows = deduplicateCsvRows(
      rows,
      existingTransactions,
    );

    final Map<String, dynamic> insertedLog = await _client
        .from('csv_import_logs')
        .insert(<String, dynamic>{
          'org_id': orgId,
          'created_by': createdBy,
          'institution': institution.label,
          'filename': filename,
          'transaction_count': 0,
        })
        .select()
        .single();

    final String logId = insertedLog['id'] as String;

    if (deduplicatedRows.isNotEmpty) {
      final List<Map<String, dynamic>> transactionPayload = deduplicatedRows
          .map((CsvRow row) {
            final String transactionId = _uuid.v4();
            return <String, dynamic>{
              'id': transactionId,
              'org_id': orgId,
              'created_by': createdBy,
              'date': _dateOnly(row.date),
              'amount': row.amount,
              'merchant': row.merchant,
              'category': row.isIncome ? 'Income' : 'Uncategorized',
              'subcategory': row.isIncome ? 'Other Income' : 'Uncategorized',
              'biz_pct': 0,
              'is_split': false,
              'source': 'csv',
              'csv_import_log_id': logId,
            };
          })
          .toList(growable: false);

      await _client.from('transactions').insert(transactionPayload);

      final List<Map<String, dynamic>> importTransactionPayload =
          transactionPayload
              .map(
                (Map<String, dynamic> row) => <String, dynamic>{
                  'import_log_id': logId,
                  'transaction_id': row['id'],
                },
              )
              .toList(growable: false);

      await _client
          .from('csv_import_transactions')
          .insert(importTransactionPayload);
    }

    final Map<String, dynamic> updatedLog = await _client
        .from('csv_import_logs')
        .update(<String, dynamic>{'transaction_count': deduplicatedRows.length})
        .eq('id', logId)
        .select()
        .single();

    return CsvImportLog.fromJson(updatedLog);
  }
}

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
