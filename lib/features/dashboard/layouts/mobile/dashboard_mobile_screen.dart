import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../settings/models/budget_default.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../presentation/providers/dashboard_provider.dart';

final NumberFormat _currencyFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
);
final NumberFormat _compactCurrencyFormat = NumberFormat.compactCurrency(
  locale: 'en_US',
  symbol: r'$',
);
const Color _businessPurple = Color(0xFF7D3C98);
const List<String> _monthInitials = <String>[
  'J',
  'F',
  'M',
  'A',
  'M',
  'J',
  'J',
  'A',
  'S',
  'O',
  'N',
  'D',
];

class DashboardMobileScreen extends ConsumerWidget {
  const DashboardMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final AsyncValue<String?> orgIdAsync = ref.watch(dashboardOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load dashboard data.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<DashboardSummary> summaryAsync = ref.watch(
          dashboardSummaryProvider(orgId, now.year),
        );
        final AsyncValue<List<BudgetDefault>> budgetsAsync = ref.watch(
          budgetDefaultsProvider(orgId),
        );
        final AsyncValue<List<Transaction>> transactionsAsync = ref.watch(
          transactionsProvider(orgId),
        );

        return summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load dashboard summary.'),
          ),
          data: (DashboardSummary summary) {
            return budgetsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) => const Center(
                child: ErrorView(message: 'Unable to load budget defaults.'),
              ),
              data: (List<BudgetDefault> budgets) {
                return transactionsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stackTrace) => const Center(
                    child: ErrorView(message: 'Unable to load transactions.'),
                  ),
                  data: (List<Transaction> transactions) {
                    final List<Transaction> sorted = List<Transaction>.from(
                      transactions,
                    )..sort(_sortByDateDesc);
                    final List<Transaction> recent = sorted
                        .take(5)
                        .toList(growable: false);
                    final List<_CategoryMonthRow> categoryRows =
                        _buildThisMonthCategoryRows(
                          transactions: sorted,
                          budgets: budgets,
                          year: now.year,
                          month: now.month,
                        );

                    final GoRouter router = GoRouter.of(context);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        AppConstants.pagePaddingMobile,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Dashboard — ${DateFormat('MMMM yyyy').format(now)}',
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          _SummaryGrid(summary: summary),
                          const SizedBox(height: AppConstants.spacingMd),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppConstants.spacingMd,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Income vs Expenses — ${now.year}',
                                    style: AppTextStyles.cardTitle,
                                  ),
                                  const SizedBox(
                                    height: AppConstants.spacingMd,
                                  ),
                                  SizedBox(
                                    height: 220,
                                    child: _IncomeExpenseBarChart(
                                      monthlyTotals: summary.monthlyTotals,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          if (transactions.isEmpty)
                            const _EmptyState()
                          else ...<Widget>[
                            _ThisMonthByCategoryCard(
                              rows: categoryRows,
                              monthLabel: DateFormat('MMM yyyy').format(now),
                              onCategoryTap: () => router.go(AppRoutes.monthly),
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            _RecentTransactionsCard(
                              recentTransactions: recent,
                              onSeeAll: () => router.go(AppRoutes.transactions),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

int _sortByDateDesc(Transaction a, Transaction b) {
  final int dateCompare = b.date.compareTo(a.date);
  if (dateCompare != 0) {
    return dateCompare;
  }
  return b.createdAt.compareTo(a.createdAt);
}

List<_CategoryMonthRow> _buildThisMonthCategoryRows({
  required List<Transaction> transactions,
  required List<BudgetDefault> budgets,
  required int year,
  required int month,
}) {
  final Map<String, double> actualByCategory = <String, double>{};
  for (final Transaction transaction in transactions) {
    if (transaction.date.year != year || transaction.date.month != month) {
      continue;
    }
    if (isIncome(transaction.category)) {
      continue;
    }

    actualByCategory[transaction.category] =
        (actualByCategory[transaction.category] ?? 0) + transaction.amount;
  }

  final Map<String, double> budgetByCategory = <String, double>{};
  for (final BudgetDefault budget in budgets) {
    if (budget.month != null || isIncome(budget.category)) {
      continue;
    }

    budgetByCategory[budget.category] =
        (budgetByCategory[budget.category] ?? 0) + budget.monthlyAmount;
  }

  final List<_CategoryMonthRow> rows =
      actualByCategory.entries
          .map(
            (MapEntry<String, double> entry) => _CategoryMonthRow(
              category: entry.key,
              actual: entry.value,
              budget: budgetByCategory[entry.key],
            ),
          )
          .toList(growable: false)
        ..sort(
          (_CategoryMonthRow a, _CategoryMonthRow b) =>
              b.actual.compareTo(a.actual),
        );

  return rows;
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double tileWidth =
            (constraints.maxWidth - AppConstants.spacingSm) / 2;

        return Wrap(
          spacing: AppConstants.spacingSm,
          runSpacing: AppConstants.spacingSm,
          children: <Widget>[
            _SummaryTile(
              width: tileWidth,
              label: 'Income',
              value: _currencyFormat.format(summary.monthIncome),
              accent: AppColors.green,
              valueColor: AppColors.green,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Expenses',
              value: _currencyFormat.format(summary.monthExpenses),
              accent: AppColors.teal,
              valueColor: AppColors.red,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Net',
              value: _currencyFormat.format(summary.monthNet),
              accent: AppColors.amber,
              valueColor: summary.monthNet >= 0
                  ? AppColors.green
                  : AppColors.red,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Business',
              value: _currencyFormat.format(summary.monthBusiness),
              accent: _businessPurple,
              valueColor: AppColors.textMuted,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.width,
    required this.label,
    required this.value,
    required this.accent,
    required this.valueColor,
  });

  final double width;
  final String label;
  final String value;
  final Color accent;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accent, width: 4)),
          ),
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: AppTextStyles.label.copyWith(fontSize: 12)),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                value,
                style: AppTextStyles.amountLarge.copyWith(
                  fontSize: 18,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomeExpenseBarChart extends StatelessWidget {
  const _IncomeExpenseBarChart({required this.monthlyTotals});

  final List<MonthlyIncomeExpense> monthlyTotals;

  @override
  Widget build(BuildContext context) {
    final List<MonthlyIncomeExpense> bars = monthlyTotals.length == 12
        ? monthlyTotals
        : List<MonthlyIncomeExpense>.generate(
            12,
            (int index) => (month: index + 1, income: 0, expenses: 0),
            growable: false,
          );
    final double maxValue = bars.fold<double>(
      0,
      (double current, MonthlyIncomeExpense month) =>
          math.max(current, math.max(month.income, month.expenses)),
    );
    final double maxY = maxValue == 0 ? 100 : (maxValue * 1.2).ceilToDouble();
    final double interval = maxY <= 100 ? 25 : maxY / 4;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (double value) =>
              const FlLine(color: AppColors.midGray, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: interval,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  _compactCurrencyFormat.format(value),
                  style: AppTextStyles.label.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index < 0 || index >= _monthInitials.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _monthInitials[index],
                  style: AppTextStyles.label.copyWith(fontSize: 11),
                );
              },
            ),
          ),
        ),
        barGroups: bars
            .asMap()
            .entries
            .map(
              (MapEntry<int, MonthlyIncomeExpense> entry) => BarChartGroupData(
                x: entry.key,
                barsSpace: 3,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: entry.value.income,
                    width: 6,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                    color: AppColors.green,
                  ),
                  BarChartRodData(
                    toY: entry.value.expenses,
                    width: 6,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                    color: AppColors.red,
                  ),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ThisMonthByCategoryCard extends StatelessWidget {
  const _ThisMonthByCategoryCard({
    required this.rows,
    required this.monthLabel,
    required this.onCategoryTap,
  });

  final List<_CategoryMonthRow> rows;
  final String monthLabel;
  final VoidCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('This Month by Category', style: AppTextStyles.cardTitle),
                const Spacer(),
                Text(monthLabel, style: AppTextStyles.label),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            if (rows.isEmpty)
              Text(
                'No expense transactions this month.',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              )
            else
              ...rows.map(
                (_CategoryMonthRow row) =>
                    _CategoryProgressRow(row: row, onTap: onCategoryTap),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({required this.row, required this.onTap});

  final _CategoryMonthRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double? budget = row.budget;
    final bool hasBudget = budget != null && budget > 0;

    Color progressColor;
    double progressValue = 0;
    if (hasBudget) {
      progressValue = row.actual / budget;
      if (progressValue < 0.8) {
        progressColor = AppColors.green;
      } else if (progressValue < 1) {
        progressColor = AppColors.amber;
      } else {
        progressColor = AppColors.red;
      }
    } else {
      progressColor = AppColors.midGray;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(row.category, style: AppTextStyles.body)),
                const SizedBox(width: AppConstants.spacingSm),
                Text(
                  _currencyFormat.format(row.actual),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasBudget) ...<Widget>[
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    '/ ${_currencyFormat.format(budget)}',
                    style: AppTextStyles.label,
                  ),
                ],
              ],
            ),
            if (hasBudget) ...<Widget>[
              const SizedBox(height: AppConstants.spacingXs),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progressValue.clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: AppColors.midGray,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({
    required this.recentTransactions,
    required this.onSeeAll,
  });

  final List<Transaction> recentTransactions;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Recent Transactions', style: AppTextStyles.cardTitle),
                const Spacer(),
                InkWell(
                  onTap: onSeeAll,
                  child: Text(
                    'See all →',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.teal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            ...recentTransactions.map(
              (Transaction transaction) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingSm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            transaction.merchant,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            '${transaction.category} • ${transaction.subcategory}',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          _currencyFormat.format(transaction.amount),
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isIncome(transaction.category)
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingXs),
                        Text(
                          DateFormat('MMM d').format(transaction.date),
                          style: AppTextStyles.label.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.bar_chart, size: 36, color: AppColors.textMuted),
            SizedBox(height: AppConstants.spacingSm),
            Text('No transactions yet', style: AppTextStyles.cardTitle),
            SizedBox(height: AppConstants.spacingXs),
            Text(
              'Add your first transaction to see your dashboard',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryMonthRow {
  const _CategoryMonthRow({
    required this.category,
    required this.actual,
    required this.budget,
  });

  final String category;
  final double actual;
  final double? budget;
}
