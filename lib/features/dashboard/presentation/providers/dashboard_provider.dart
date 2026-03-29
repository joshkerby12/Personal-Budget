import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

part 'dashboard_provider.g.dart';

typedef RangeIncomeExpense = ({
  DateTime monthStart,
  double income,
  double expenses,
});

enum DashboardRange { thisMonth, last3Months, last6Months, yearToDate }

String dashboardRangeLabel(DashboardRange range) {
  switch (range) {
    case DashboardRange.thisMonth:
      return 'This Month';
    case DashboardRange.last3Months:
      return 'Last 3 Months';
    case DashboardRange.last6Months:
      return 'Last 6 Months';
    case DashboardRange.yearToDate:
      return 'Year to Date';
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.rangeIncome,
    required this.rangeExpenses,
    required this.rangeNet,
    required this.rangeBusiness,
    required this.monthlyTotals,
    required this.categoryTotals,
  });

  final DashboardRange range;
  final DateTime startDate;
  final DateTime endDate;
  final double rangeIncome;
  final double rangeExpenses;
  final double rangeNet;
  final double rangeBusiness;
  final List<RangeIncomeExpense> monthlyTotals;
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
  DashboardRange range,
) async {
  final DateTime now = DateTime.now();
  final ({DateTime startDate, DateTime endDate}) bounds = _resolveBounds(
    range,
    now,
  );

  final List<Transaction> allTransactions = await ref.watch(
    transactionsProvider(orgId).future,
  );

  final List<Transaction> rangedTransactions = allTransactions
      .where(
        (Transaction t) =>
            !t.date.isBefore(bounds.startDate) &&
            !t.date.isAfter(bounds.endDate),
      )
      .toList(growable: false);

  final ({double income, double expenses, double net, double businessTotal})
  rangeSummary = calculateTransactionSummary(rangedTransactions);

  final List<DateTime> monthStarts = _monthStartsInRange(range, now);
  final List<RangeIncomeExpense> monthlyTotals = monthStarts
      .map((DateTime monthStart) {
        final DateTime monthEnd = DateTime(
          monthStart.year,
          monthStart.month + 1,
          1,
        );
        final List<Transaction> monthTransactions = rangedTransactions
            .where(
              (Transaction t) =>
                  !t.date.isBefore(monthStart) && t.date.isBefore(monthEnd),
            )
            .toList(growable: false);
        final ({
          double income,
          double expenses,
          double net,
          double businessTotal,
        })
        monthSummary = calculateTransactionSummary(monthTransactions);
        return (
          monthStart: monthStart,
          income: monthSummary.income,
          expenses: monthSummary.expenses,
        );
      })
      .toList(growable: false);

  final Map<String, double> categoryTotals = <String, double>{};
  for (final Transaction transaction in rangedTransactions) {
    if (isIncome(transaction.category)) {
      continue;
    }
    categoryTotals[transaction.category] =
        (categoryTotals[transaction.category] ?? 0) + transaction.amount;
  }

  return DashboardSummary(
    range: range,
    startDate: bounds.startDate,
    endDate: bounds.endDate,
    rangeIncome: rangeSummary.income,
    rangeExpenses: rangeSummary.expenses,
    rangeNet: rangeSummary.net,
    rangeBusiness: rangeSummary.businessTotal,
    monthlyTotals: monthlyTotals,
    categoryTotals: categoryTotals,
  );
}

({DateTime startDate, DateTime endDate}) _resolveBounds(
  DashboardRange range,
  DateTime now,
) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  switch (range) {
    case DashboardRange.thisMonth:
      return (startDate: DateTime(now.year, now.month, 1), endDate: today);
    case DashboardRange.last3Months:
      return (startDate: DateTime(now.year, now.month - 2, 1), endDate: today);
    case DashboardRange.last6Months:
      return (startDate: DateTime(now.year, now.month - 5, 1), endDate: today);
    case DashboardRange.yearToDate:
      return (startDate: DateTime(now.year, 1, 1), endDate: today);
  }
}

List<DateTime> _monthStartsInRange(DashboardRange range, DateTime now) {
  final DateTime currentMonth = DateTime(now.year, now.month, 1);
  switch (range) {
    case DashboardRange.thisMonth:
      return <DateTime>[currentMonth];
    case DashboardRange.last3Months:
      return List<DateTime>.generate(
        3,
        (int index) => DateTime(now.year, now.month - 2 + index, 1),
        growable: false,
      );
    case DashboardRange.last6Months:
      return List<DateTime>.generate(
        6,
        (int index) => DateTime(now.year, now.month - 5 + index, 1),
        growable: false,
      );
    case DashboardRange.yearToDate:
      return List<DateTime>.generate(
        now.month,
        (int index) => DateTime(now.year, index + 1, 1),
        growable: false,
      );
  }
}
