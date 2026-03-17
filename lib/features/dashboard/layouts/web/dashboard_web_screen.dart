import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../settings/models/budget_default.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/models/transaction_filter.dart';
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

const List<Color> _donutColors = <Color>[
  AppColors.teal,
  AppColors.green,
  AppColors.amber,
  AppColors.navy,
  _businessPurple,
  AppColors.red,
  AppColors.lightGray,
];

final AutoDisposeStateProvider<int> _selectedYearProvider =
    StateProvider.autoDispose<int>((Ref ref) => DateTime.now().year);

class DashboardWebScreen extends ConsumerWidget {
  const DashboardWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentYear = DateTime.now().year;
    final int selectedYear = ref.watch(_selectedYearProvider);
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
          dashboardSummaryProvider(orgId, selectedYear),
        );
        final AsyncValue<List<BudgetDefault>> budgetsAsync = ref.watch(
          budgetDefaultsProvider(orgId),
        );
        final AsyncValue<List<Transaction>> transactionsAsync = ref.watch(
          transactionsProvider(
            orgId,
            filter: TransactionFilter(year: selectedYear),
          ),
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
                  data: (List<Transaction> yearTransactions) {
                    final _CategoryTableData tableData =
                        _buildCategoryTableData(yearTransactions, budgets);
                    final List<int> yearOptions = List<int>.generate(
                      5,
                      (int index) => currentYear - 2 + index,
                      growable: false,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.pagePaddingDesktop,
                      ),
                      child: ListView(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('Dashboard', style: AppTextStyles.pageTitle),
                              const Spacer(),
                              SizedBox(
                                width: 130,
                                child: DropdownButtonFormField<int>(
                                  key: ValueKey<int>(selectedYear),
                                  initialValue: selectedYear,
                                  decoration: const InputDecoration(
                                    labelText: 'Year',
                                  ),
                                  items: yearOptions
                                      .map(
                                        (int year) => DropdownMenuItem<int>(
                                          value: year,
                                          child: Text(year.toString()),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      ref
                                              .read(
                                                _selectedYearProvider.notifier,
                                              )
                                              .state =
                                          value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          _SummaryStatCards(summary: summary),
                          const SizedBox(height: AppConstants.spacingMd),
                          _ChartGrid(summary: summary, year: selectedYear),
                          const SizedBox(height: AppConstants.spacingMd),
                          _CategoryTotalsTable(
                            rows: tableData.rows,
                            totalActual: tableData.totalActual,
                            totalBudget: tableData.totalBudget,
                            totalBusiness: tableData.totalBusiness,
                            selectedYear: selectedYear,
                            hasTransactions: yearTransactions.isNotEmpty,
                          ),
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

_CategoryTableData _buildCategoryTableData(
  List<Transaction> yearTransactions,
  List<BudgetDefault> budgets,
) {
  final Map<String, double> actualByCategory = <String, double>{};
  final Map<String, double> businessByCategory = <String, double>{};
  for (final Transaction transaction in yearTransactions) {
    if (isIncome(transaction.category)) {
      continue;
    }

    actualByCategory[transaction.category] =
        (actualByCategory[transaction.category] ?? 0) + transaction.amount;
    businessByCategory[transaction.category] =
        (businessByCategory[transaction.category] ?? 0) +
        calculateBusinessAmount(transaction.amount, transaction.bizPct);
  }

  final Map<String, double> budgetByCategory = <String, double>{};
  for (final BudgetDefault budget in budgets) {
    if (budget.month != null || isIncome(budget.category)) {
      continue;
    }

    budgetByCategory[budget.category] =
        (budgetByCategory[budget.category] ?? 0) + budget.monthlyAmount;
  }

  final List<_CategoryTableRowData> rows =
      actualByCategory.keys
          .map(
            (String category) => _CategoryTableRowData(
              category: category,
              actual: actualByCategory[category] ?? 0,
              budget: budgetByCategory[category],
              business: businessByCategory[category] ?? 0,
            ),
          )
          .toList(growable: false)
        ..sort(
          (_CategoryTableRowData a, _CategoryTableRowData b) =>
              a.category.compareTo(b.category),
        );

  final double totalActual = rows.fold<double>(
    0,
    (double sum, _CategoryTableRowData row) => sum + row.actual,
  );
  final double totalBusiness = rows.fold<double>(
    0,
    (double sum, _CategoryTableRowData row) => sum + row.business,
  );
  final double totalBudget = rows.fold<double>(
    0,
    (double sum, _CategoryTableRowData row) => sum + (row.budget ?? 0),
  );

  return _CategoryTableData(
    rows: rows,
    totalActual: totalActual,
    totalBudget: totalBudget,
    totalBusiness: totalBusiness,
  );
}

class _SummaryStatCards extends StatelessWidget {
  const _SummaryStatCards({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 980) {
          final double width =
              (constraints.maxWidth - AppConstants.spacingSm) / 2;
          return Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: <Widget>[
              _SummaryStatCard(
                width: width,
                label: 'Income',
                total: summary.yearIncome,
                month: summary.monthIncome,
                accent: AppColors.green,
                valueColor: AppColors.green,
              ),
              _SummaryStatCard(
                width: width,
                label: 'Expenses',
                total: summary.yearExpenses,
                month: summary.monthExpenses,
                accent: AppColors.teal,
                valueColor: AppColors.red,
              ),
              _SummaryStatCard(
                width: width,
                label: 'Net',
                total: summary.yearNet,
                month: summary.monthNet,
                accent: AppColors.amber,
                valueColor: summary.yearNet >= 0
                    ? AppColors.green
                    : AppColors.red,
              ),
              _SummaryStatCard(
                width: width,
                label: 'Business',
                total: summary.yearBusiness,
                month: summary.monthBusiness,
                accent: _businessPurple,
                valueColor: AppColors.textMuted,
              ),
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(
              child: _SummaryStatCard(
                label: 'Income',
                total: summary.yearIncome,
                month: summary.monthIncome,
                accent: AppColors.green,
                valueColor: AppColors.green,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _SummaryStatCard(
                label: 'Expenses',
                total: summary.yearExpenses,
                month: summary.monthExpenses,
                accent: AppColors.teal,
                valueColor: AppColors.red,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _SummaryStatCard(
                label: 'Net',
                total: summary.yearNet,
                month: summary.monthNet,
                accent: AppColors.amber,
                valueColor: summary.yearNet >= 0
                    ? AppColors.green
                    : AppColors.red,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: _SummaryStatCard(
                label: 'Business',
                total: summary.yearBusiness,
                month: summary.monthBusiness,
                accent: _businessPurple,
                valueColor: AppColors.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.total,
    required this.month,
    required this.accent,
    required this.valueColor,
    this.width,
  });

  final String label;
  final double total;
  final double month;
  final Color accent;
  final Color valueColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final Widget card = Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              _currencyFormat.format(total),
              style: AppTextStyles.amountLarge.copyWith(
                fontSize: 22,
                color: valueColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'This month: ${_currencyFormat.format(month)}',
              style: AppTextStyles.label.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );

    if (width == null) {
      return card;
    }

    return SizedBox(width: width, child: card);
  }
}

class _ChartGrid extends StatelessWidget {
  const _ChartGrid({required this.summary, required this.year});

  final DashboardSummary summary;
  final int year;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget barCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Income vs Expenses — $year',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                SizedBox(
                  height: 260,
                  child: _IncomeExpenseBarChart(
                    monthlyTotals: summary.monthlyTotals,
                  ),
                ),
              ],
            ),
          ),
        );

        final Widget donutCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Expense Breakdown', style: AppTextStyles.cardTitle),
                const SizedBox(height: AppConstants.spacingMd),
                SizedBox(
                  height: 260,
                  child: _ExpenseDonutChart(
                    categoryTotals: summary.categoryTotals,
                  ),
                ),
              ],
            ),
          ),
        );

        if (constraints.maxWidth < 1040) {
          return Column(
            children: <Widget>[
              barCard,
              const SizedBox(height: AppConstants.spacingSm),
              donutCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: barCard),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(child: donutCard),
          ],
        );
      },
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
              reservedSize: 46,
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
                barsSpace: 4,
                barRods: <BarChartRodData>[
                  BarChartRodData(
                    toY: entry.value.income,
                    width: 8,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                    color: AppColors.green,
                  ),
                  BarChartRodData(
                    toY: entry.value.expenses,
                    width: 8,
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

class _ExpenseDonutChart extends StatelessWidget {
  const _ExpenseDonutChart({required this.categoryTotals});

  final Map<String, double> categoryTotals;

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return PieChart(
        PieChartData(
          centerSpaceRadius: 52,
          sectionsSpace: 2,
          sections: <PieChartSectionData>[
            PieChartSectionData(
              value: 1,
              color: AppColors.lightGray,
              radius: 42,
              title: 'No Data',
              titleStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    final List<MapEntry<String, double>> entries =
        categoryTotals.entries.toList(growable: false)..sort(
          (MapEntry<String, double> a, MapEntry<String, double> b) =>
              b.value.compareTo(a.value),
        );

    final double total = entries.fold<double>(
      0,
      (double sum, MapEntry<String, double> entry) => sum + entry.value,
    );

    return PieChart(
      PieChartData(
        centerSpaceRadius: 52,
        sectionsSpace: 2,
        sections: entries
            .asMap()
            .entries
            .map((MapEntry<int, MapEntry<String, double>> entry) {
              final String category = entry.value.key;
              final double amount = entry.value.value;
              final double percentage = total == 0 ? 0 : (amount / total) * 100;
              final Color color = _donutColors[entry.key % _donutColors.length];

              return PieChartSectionData(
                value: amount,
                color: color,
                radius: 42,
                title: '$category ${percentage.toStringAsFixed(0)}%',
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _CategoryTotalsTable extends StatelessWidget {
  const _CategoryTotalsTable({
    required this.rows,
    required this.totalActual,
    required this.totalBudget,
    required this.totalBusiness,
    required this.selectedYear,
    required this.hasTransactions,
  });

  final List<_CategoryTableRowData> rows;
  final double totalActual;
  final double totalBudget;
  final double totalBusiness;
  final int selectedYear;
  final bool hasTransactions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Category Totals', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            if (!hasTransactions)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingXl,
                ),
                child: Center(
                  child: Text(
                    'No transactions for $selectedYear',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 980),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: AppColors.navy,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        child: const Row(
                          children: <Widget>[
                            _HeaderCell('Category', flex: 3),
                            _HeaderCell('Actual (\$)', flex: 2),
                            _HeaderCell('Budget/mo (\$)', flex: 2),
                            _HeaderCell('Business (\$)', flex: 2),
                            _HeaderCell('Biz%', flex: 1),
                          ],
                        ),
                      ),
                      ...rows.asMap().entries.map((
                        MapEntry<int, _CategoryTableRowData> entry,
                      ) {
                        final bool isEven = entry.key.isEven;
                        final _CategoryTableRowData row = entry.value;
                        return Container(
                          color: isEven ? AppColors.white : AppColors.lightGray,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMd,
                            vertical: AppConstants.spacingSm,
                          ),
                          child: Row(
                            children: <Widget>[
                              _BodyCell(row.category, flex: 3),
                              _BodyCell(
                                _currencyFormat.format(row.actual),
                                flex: 2,
                                alignRight: true,
                              ),
                              _BodyCell(
                                row.budget == null
                                    ? '—'
                                    : _currencyFormat.format(row.budget),
                                flex: 2,
                                alignRight: true,
                              ),
                              _BodyCell(
                                _currencyFormat.format(row.business),
                                flex: 2,
                                alignRight: true,
                              ),
                              _BodyCell(
                                row.actual == 0
                                    ? '—'
                                    : '${((row.business / row.actual) * 100).toStringAsFixed(0)}%',
                                flex: 1,
                                alignRight: true,
                              ),
                            ],
                          ),
                        );
                      }),
                      Container(
                        color: AppColors.tealLight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Totals',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _FooterCell(
                              _currencyFormat.format(totalActual),
                              flex: 2,
                            ),
                            _FooterCell(
                              _currencyFormat.format(totalBudget),
                              flex: 2,
                            ),
                            _FooterCell(
                              _currencyFormat.format(totalBusiness),
                              flex: 2,
                            ),
                            _FooterCell(
                              totalActual == 0
                                  ? '—'
                                  : '${((totalBusiness / totalActual) * 100).toStringAsFixed(0)}%',
                              flex: 1,
                            ),
                          ],
                        ),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.button.copyWith(
          fontSize: 12,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.value, {required this.flex, this.alignRight = false});

  final String value;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: AppTextStyles.body,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _FooterCell extends StatelessWidget {
  const _FooterCell(this.value, {required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        textAlign: TextAlign.right,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CategoryTableData {
  const _CategoryTableData({
    required this.rows,
    required this.totalActual,
    required this.totalBudget,
    required this.totalBusiness,
  });

  final List<_CategoryTableRowData> rows;
  final double totalActual;
  final double totalBudget;
  final double totalBusiness;
}

class _CategoryTableRowData {
  const _CategoryTableRowData({
    required this.category,
    required this.actual,
    required this.budget,
    required this.business,
  });

  final String category;
  final double actual;
  final double? budget;
  final double business;
}
