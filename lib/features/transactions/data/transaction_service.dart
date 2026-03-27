import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction.dart';
import '../models/transaction_filter.dart';

class TransactionService {
  const TransactionService(this._client);

  final SupabaseClient _client;

  Future<List<Transaction>> fetchTransactions(
    String orgId, {
    TransactionFilter filter = const TransactionFilter(),
  }) async {
    dynamic query = _client.from('transactions').select().eq('org_id', orgId);

    if (filter.year != null) {
      if (filter.month != null) {
        final DateTime start = DateTime(filter.year!, filter.month!, 1);
        final DateTime end = DateTime(filter.year!, filter.month! + 1, 1);
        query = query.gte('date', _dateOnly(start)).lt('date', _dateOnly(end));
      } else {
        final DateTime start = DateTime(filter.year!, 1, 1);
        final DateTime end = DateTime(filter.year! + 1, 1, 1);
        query = query.gte('date', _dateOnly(start)).lt('date', _dateOnly(end));
      }
    }

    final String? category = filter.category?.trim();
    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (filter.bizOnly == true) {
      query = query.gt('biz_pct', 0);
    }

    final List<dynamic> rows = await query
        .order('date', ascending: false)
        .order('created_at', ascending: false);

    return rows
        .cast<Map<String, dynamic>>()
        .map(Transaction.fromJson)
        .toList(growable: false);
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save a transaction.');
    }

    await _client.from('transactions').insert(<String, dynamic>{
      'org_id': transaction.orgId,
      'created_by': userId,
      'date': _dateOnly(transaction.date),
      'amount': transaction.amount,
      'merchant': transaction.merchant,
      'description': transaction.description,
      'category': transaction.category,
      'subcategory': transaction.subcategory,
      'biz_pct': transaction.bizPct,
      'is_split': transaction.isSplit,
      'receipt_id': transaction.receiptId,
      'notes': transaction.notes,
      'no_miles': transaction.noMiles,
      'created_at': transaction.createdAt.toUtc().toIso8601String(),
    });
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _client
        .from('transactions')
        .update(<String, dynamic>{
          'date': _dateOnly(transaction.date),
          'amount': transaction.amount,
          'merchant': transaction.merchant,
          'description': transaction.description,
          'category': transaction.category,
          'subcategory': transaction.subcategory,
          'biz_pct': transaction.bizPct,
          'is_split': transaction.isSplit,
          'receipt_id': transaction.receiptId,
          'notes': transaction.notes,
          'no_miles': transaction.noMiles,
        })
        .eq('id', transaction.id);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _client.from('transactions').delete().eq('id', transactionId);
  }
}

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
