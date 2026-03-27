import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/transaction_service.dart';
import '../../models/transaction.dart';
import '../../models/transaction_filter.dart';

part 'transaction_provider.g.dart';

@Riverpod(keepAlive: true)
TransactionService transactionService(Ref ref) {
  return TransactionService(ref.watch(supabaseClientProvider));
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
class TransactionController extends _$TransactionController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> save(Transaction transaction, {bool isEdit = false}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      if (isEdit) {
        await ref
            .read(transactionServiceProvider)
            .updateTransaction(transaction);
      } else {
        await ref
            .read(transactionServiceProvider)
            .insertTransaction(transaction);
      }

      ref.invalidate(transactionsProvider(transaction.orgId));
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

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
