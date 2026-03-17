import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/models/transaction_filter.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

part 'dashboard_provider.g.dart';

typedef MonthlyIncomeExpense = ({int month, double income, double expenses});

class DashboardSummary {
  const DashboardSummary({
    required this.yearIncome,
    required this.yearExpenses,
    required this.yearNet,
    required this.yearBusiness,
    required this.monthIncome,
    required this.monthExpenses,
    required this.monthNet,
    required this.monthBusiness,
    required this.monthlyTotals,
    required this.categoryTotals,
  });

  final double yearIncome;
  final double yearExpenses;
  final double yearNet;
  final double yearBusiness;
  final double monthIncome;
  final double monthExpenses;
  final double monthNet;
  final double monthBusiness;
  final List<MonthlyIncomeExpense> monthlyTotals;
  final Map<String, double> categoryTotals;
}

@riverpod
Future<String?> dashboardOrgId(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null) {
    return null;
  }

  final Map<String, dynamic>? row = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  return row?['org_id'] as String?;
}

@riverpod
Future<DashboardSummary> dashboardSummary(
  Ref ref,
  String orgId,
  int year,
) async {
  final List<Transaction> allYear = await ref.watch(
    transactionsProvider(orgId, filter: TransactionFilter(year: year)).future,
  );

  final ({double income, double expenses, double net, double businessTotal})
  yearSummary = calculateTransactionSummary(allYear);

  final DateTime now = DateTime.now();
  final List<Transaction> monthTransactions = allYear
      .where((Transaction t) => t.date.month == now.month)
      .toList(growable: false);
  final ({double income, double expenses, double net, double businessTotal})
  monthSummary = calculateTransactionSummary(monthTransactions);

  final List<MonthlyIncomeExpense>
  monthlyTotals = List<MonthlyIncomeExpense>.generate(12, (int index) {
    final int month = index + 1;
    final List<Transaction> monthTxns = allYear
        .where((Transaction transaction) => transaction.date.month == month)
        .toList(growable: false);
    final ({double income, double expenses, double net, double businessTotal})
    summary = calculateTransactionSummary(monthTxns);

    return (month: month, income: summary.income, expenses: summary.expenses);
  }, growable: false);

  final Map<String, double> categoryTotals = <String, double>{};
  for (final Transaction transaction in allYear) {
    if (isIncome(transaction.category)) {
      continue;
    }

    categoryTotals[transaction.category] =
        (categoryTotals[transaction.category] ?? 0) + transaction.amount;
  }

  return DashboardSummary(
    yearIncome: yearSummary.income,
    yearExpenses: yearSummary.expenses,
    yearNet: yearSummary.net,
    yearBusiness: yearSummary.businessTotal,
    monthIncome: monthSummary.income,
    monthExpenses: monthSummary.expenses,
    monthNet: monthSummary.net,
    monthBusiness: monthSummary.businessTotal,
    monthlyTotals: monthlyTotals,
    categoryTotals: categoryTotals,
  );
}
