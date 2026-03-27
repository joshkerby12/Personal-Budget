import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../../settings/data/settings_service.dart';
import '../../settings/models/budget_default.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import '../../transactions/helpers/transaction_calculations.dart';
import '../../transactions/models/transaction.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import '../../transactions/presentation/widgets/transaction_form.dart';
import '../presentation/providers/monthly_provider.dart';
import 'month_selector.dart';

const List<Color> _categoryPalette = <Color>[
  AppColors.teal,
  AppColors.green,
  AppColors.amber,
  AppColors.navy,
  AppColors.red,
  Color(0xFF6C8EBF),
  Color(0xFF8E44AD),
  Color(0xFF16A085),
  Color(0xFF7D6608),
  Color(0xFF1F618D),
];

String _normalizeMerchant(String merchant) {
  final String upper = merchant.toUpperCase();
  final String stripped = upper.replaceAll(RegExp(r'[^A-Z ]'), '');
  final List<String> tokens = stripped
      .split(' ')
      .where((String token) => token.isNotEmpty)
      .toList();
  return tokens.take(4).join(' ');
}

class MonthlyBudgetView extends ConsumerStatefulWidget {
  const MonthlyBudgetView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  ConsumerState<MonthlyBudgetView> createState() => _MonthlyBudgetViewState();
}

class _MonthlyBudgetViewState extends ConsumerState<MonthlyBudgetView> {
  final NumberFormat _currency = NumberFormat.currency(symbol: r'$');
  final DateFormat _transactionDate = DateFormat('MMM d');

  late final ValueNotifier<int> _selectedMonthNotifier;
  final ValueNotifier<bool> _isEditingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<Set<String>> _editedKeysNotifier =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<Set<String>> _collapsedCategoriesNotifier =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<Set<String>> _expandedSubcategoryKeysNotifier =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<String?> _inlineEditingKeyNotifier =
      ValueNotifier<String?>(null);

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, MonthlyRow> _editingRows = <String, MonthlyRow>{};
  TextEditingController? _inlineController;
  TextEditingController? _inlineBizPctController;
  double? _lastMonthActual;
  bool _isUncategorizedExpanded = true;

  late final int _selectedYear;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonthNotifier = ValueNotifier<int>(now.month);
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _editingRows.clear();
    _selectedMonthNotifier.dispose();
    _isEditingNotifier.dispose();
    _editedKeysNotifier.dispose();
    _collapsedCategoriesNotifier.dispose();
    _expandedSubcategoryKeysNotifier.dispose();
    _inlineEditingKeyNotifier.dispose();
    _inlineController?.dispose();
    _inlineBizPctController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<String?> orgIdAsync = ref.watch(monthlyOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load monthly budget data.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        return ValueListenableBuilder<int>(
          valueListenable: _selectedMonthNotifier,
          builder: (BuildContext context, int selectedMonth, _) {
            final AsyncValue<MonthlyBudgetData> budgetDataAsync = ref.watch(
              monthlyBudgetDataProvider(orgId, _selectedYear, selectedMonth),
            );

            return budgetDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) => const Center(
                child: ErrorView(
                  message: 'Unable to load monthly budget details right now.',
                ),
              ),
              data: (MonthlyBudgetData data) =>
                  _buildScaffold(context, orgId, data),
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    String orgId,
    MonthlyBudgetData data,
  ) {
    final Map<String, List<MonthlyRow>> groupedRows = _groupRows(data.rows);

    // Auto-collapse all categories on mobile if none have been manually toggled
    if (widget.isMobile && _collapsedCategoriesNotifier.value.isEmpty && groupedRows.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _collapsedCategoriesNotifier.value = groupedRows.keys.toSet();
        }
      });
    }
    final List<Transaction> uncategorizedTransactions =
        _filterUncategorizedTransactions(data);
    final AsyncValue<List<Transaction>> historyAsync =
        uncategorizedTransactions.isEmpty
        ? const AsyncData<List<Transaction>>(<Transaction>[])
        : ref.watch(recentCategorizedTransactionsProvider(orgId));
    final List<Transaction> suggestionHistory =
        historyAsync.valueOrNull ?? const <Transaction>[];

    final EdgeInsets padding = EdgeInsets.all(
      widget.isMobile
          ? AppConstants.pagePaddingMobile
          : AppConstants.pagePaddingDesktop,
    );

    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Monthly Budget', style: AppTextStyles.pageTitle),
        const SizedBox(height: AppConstants.spacingMd),
        MonthSelector(
          selectedMonth: data.month,
          onChanged: (int month) => _handleMonthChange(month),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (widget.isMobile) ...<Widget>[
          _buildMobileSummaryRow(data.rows),
          const SizedBox(height: AppConstants.spacingSm),
          _buildUncategorizedPanel(
            context,
            orgId: orgId,
            data: data,
            transactions: uncategorizedTransactions,
            suggestionHistory: suggestionHistory,
          ),
          if (uncategorizedTransactions.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMd),
        ],
        if (!_hasTransactions(data.rows)) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingMd,
            ),
            alignment: Alignment.center,
            child: Text(
              'No transactions for ${_monthName(data.month)} ${data.year}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],
        if (widget.isMobile)
          _buildMobileCategoryGroups(
            Map<String, List<MonthlyRow>>.fromEntries(
              groupedRows.entries.where(
                (MapEntry<String, List<MonthlyRow>> e) => !isTransfer(e.key),
              ),
            ),
            data.categorySubtotals,
          )
        else ...<Widget>[
          _buildSummaryCharts(data),
          const SizedBox(height: AppConstants.spacingMd),
          _buildUncategorizedPanel(
            context,
            orgId: orgId,
            data: data,
            transactions: uncategorizedTransactions,
            suggestionHistory: suggestionHistory,
          ),
          if (uncategorizedTransactions.isNotEmpty)
            const SizedBox(height: AppConstants.spacingMd),
          _buildDesktopTable(orgId, data, groupedRows, data.categorySubtotals),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        if (data.isOverBudget) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.amberFill,
              borderRadius: BorderRadius.circular(AppConstants.spacingSm),
              border: Border.all(color: AppColors.amber),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.amber,
                  size: 18,
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    'Total budgeted expenses (\$${_currency.format(data.totalBudgeted).replaceAll(r'$', '')}) exceed '
                    'income for this month (\$${_currency.format(data.monthIncome).replaceAll(r'$', '')}). '
                    'You may be drawing from savings.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.amber,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
        ],
        ValueListenableBuilder<bool>(
          valueListenable: _isEditingNotifier,
          builder: (BuildContext context, bool isEditing, _) {
            return _buildToolbar(context, orgId, data, isEditing);
          },
        ),
      ],
    );

    final Widget wrappedContent = widget.isMobile
        ? SingleChildScrollView(child: content)
        : SingleChildScrollView(child: content);

    return SizedBox.expand(
      child: Padding(padding: padding, child: wrappedContent),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    String orgId,
    MonthlyBudgetData data,
    bool isEditing,
  ) {
    final bool hasCustomBudgets = data.hasCustomBudgets;
    final String monthName = _monthName(data.month);

    final Widget rightContent = isEditing
        ? Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            alignment: WrapAlignment.end,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _copyDefaults,
                icon: const Icon(Icons.content_paste_outlined, size: 16),
                label: const Text('Copy Defaults'),
              ),
              OutlinedButton.icon(
                onPressed: _cancelEditing,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () => _saveMonthBudgets(context, orgId, data),
                icon: const Icon(Icons.save_outlined, size: 16),
                label: Text('Save $monthName Budgets'),
              ),
            ],
          )
        : Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            alignment: WrapAlignment.end,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: () => _startEditing(data.rows),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit Budgets'),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyAndSaveDefaults(context, orgId, data),
                icon: const Icon(Icons.content_paste_outlined, size: 16),
                label: const Text('Copy Global Defaults'),
              ),
              if (hasCustomBudgets)
                OutlinedButton.icon(
                  onPressed: () => _clearOverrides(context, orgId, data),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Clear Overrides'),
                ),
            ],
          );

    final BoxDecoration decoration = BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.spacingSm),
      border: Border.all(color: AppColors.border),
    );

    final BoxDecoration editingDecoration = BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.spacingSm),
      border: const Border(
        top: BorderSide(color: AppColors.border),
        right: BorderSide(color: AppColors.border),
        bottom: BorderSide(color: AppColors.border),
        left: BorderSide(color: AppColors.amber, width: 4),
      ),
    );

    return Container(
      decoration: isEditing ? editingDecoration : decoration,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                '$monthName ${data.year} Budgets',
                style: AppTextStyles.cardTitle,
              ),
              if (isEditing)
                _Badge(
                  text: '✏ EDITING $monthName',
                  background: AppColors.amber,
                  textColor: AppColors.white,
                )
              else if (hasCustomBudgets)
                _Badge(
                  text: '✔ Custom budgets set',
                  background: AppColors.teal,
                  textColor: AppColors.white,
                )
              else
                const _Badge(
                  text: 'Using default budgets',
                  background: AppColors.lightGray,
                  textColor: AppColors.text,
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Align(alignment: Alignment.centerRight, child: rightContent),
        ],
      ),
    );
  }

  Widget _buildMobileSummaryRow(List<MonthlyRow> rows) {
    final ({double income, double expenses, double net}) summary =
        _incomeExpenseSummary(rows);

    final TextStyle muted = AppTextStyles.label.copyWith(
      color: AppColors.textMuted,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(
        'Income: ${_formatCurrency(summary.income)} | '
        'Expenses: ${_formatCurrency(summary.expenses)} | '
        'Net: ${_formatCurrency(summary.net)}',
        style: muted.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildMobileCategoryGroups(
    Map<String, List<MonthlyRow>> groupedRows,
    Map<String, ({double budget, double actual, double business})> subtotals,
  ) {
    if (groupedRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isEditingNotifier,
      builder: (BuildContext context, bool isEditing, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: _editedKeysNotifier,
          builder: (BuildContext context, Set<String> editedKeys, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: _collapsedCategoriesNotifier,
              builder: (BuildContext context, Set<String> collapsedCategories, _) {
                return Column(
                  children: groupedRows.entries
                      .map((MapEntry<String, List<MonthlyRow>> entry) {
                        final String category = entry.key;
                        final List<MonthlyRow> rows = entry.value;
                        final bool isCollapsed = collapsedCategories.contains(
                          category,
                        );
                        final ({double budget, double actual, double business})
                        subtotal =
                            subtotals[category] ??
                            (budget: 0, actual: 0, business: 0);

                        final double personal =
                            subtotal.actual - subtotal.business;
                        final double bizPct = subtotal.actual > 0
                            ? subtotal.business / subtotal.actual
                            : 0;

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.spacingSm,
                          ),
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () => _toggleCategory(category),
                                child: Container(
                                  color: isIncome(category)
                                      ? AppColors.green
                                      : AppColors.navy,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingMd,
                                    vertical: AppConstants.spacingSm,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        isCollapsed
                                            ? Icons.keyboard_arrow_right
                                            : Icons.keyboard_arrow_down,
                                        color: AppColors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(
                                        width: AppConstants.spacingXs,
                                      ),
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: AppTextStyles.cardTitle
                                              .copyWith(color: AppColors.white),
                                        ),
                                      ),
                                      Text(
                                        'Actual ${_formatCurrency(subtotal.actual)} / '
                                        'Budget ${_formatCurrency(subtotal.budget)}',
                                        style: AppTextStyles.label.copyWith(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isCollapsed)
                                Padding(
                                  padding: const EdgeInsets.all(
                                    AppConstants.spacingSm,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _BudgetActualBar(
                                        budget: subtotal.budget,
                                        actual: subtotal.actual,
                                        formatCurrency: _formatCurrency,
                                        formatBudget: _formatCurrency,
                                      ),
                                      const SizedBox(
                                        height: AppConstants.spacingXs,
                                      ),
                                      Text(
                                        'Personal: ${_formatCurrency(personal)} | '
                                        'Business: ${_formatCurrency(subtotal.business)} | '
                                        'Biz: ${(bizPct * 100).toStringAsFixed(0)}%',
                                        style: AppTextStyles.label.copyWith(
                                          color: AppColors.text,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (!isCollapsed)
                                Padding(
                                  padding: const EdgeInsets.all(
                                    AppConstants.spacingSm,
                                  ),
                                  child: Column(
                                    children: rows
                                        .map(
                                          (MonthlyRow row) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: AppConstants.spacingSm,
                                            ),
                                            child: _buildMobileRow(
                                              context,
                                              row,
                                              isEditing,
                                              isEdited: editedKeys.contains(
                                                row.key,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                ),
                            ],
                          ),
                        );
                      })
                      .toList(growable: false),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMobileRow(
    BuildContext context,
    MonthlyRow row,
    bool isEditing, {
    required bool isEdited,
  }) {
    final bool hasBudget = row.budget > 0;

    return InkWell(
      onTap: isEditing ? () => _editMobileRowBudget(context, row) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: isEdited ? AppColors.amberFill : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.spacingSm),
          border: Border(
            left: BorderSide(
              color: row.hasCustomBudget ? AppColors.amber : AppColors.border,
              width: row.hasCustomBudget ? 3 : 1,
            ),
            top: const BorderSide(color: AppColors.border),
            right: const BorderSide(color: AppColors.border),
            bottom: const BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(row.subcategory, style: AppTextStyles.cardTitle),
                ),
                if (isEditing)
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.amber,
                  ),
                Text(
                  _formatCurrency(row.remaining),
                  style: AppTextStyles.body.copyWith(
                    color: row.remaining >= 0 ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'Budget: ${_formatBudget(row.budget)} | '
              'Actual: ${_formatCurrency(row.actual)}',
              style: AppTextStyles.body.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'Personal: ${_formatCurrency(row.personal)} | '
              'Business: ${_formatCurrency(row.business)} | '
              'Biz: ${(row.bizPct * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.label.copyWith(color: AppColors.text),
            ),
            if (hasBudget) ...<Widget>[
              const SizedBox(height: AppConstants.spacingXs),
              _ProgressBar(budget: row.budget, actual: row.actual),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable(
    String orgId,
    MonthlyBudgetData data,
    Map<String, List<MonthlyRow>> groupedRows,
    Map<String, ({double budget, double actual, double business})> subtotals,
  ) {
    if (groupedRows.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, List<MonthlyRow>> incomeGroups =
        <String, List<MonthlyRow>>{};
    final Map<String, List<MonthlyRow>> expenseGroups =
        <String, List<MonthlyRow>>{};
    for (final MapEntry<String, List<MonthlyRow>> entry
        in groupedRows.entries) {
      if (isIncome(entry.key)) {
        incomeGroups[entry.key] = entry.value;
      } else {
        expenseGroups[entry.key] = entry.value;
      }
    }

    // Assign palette colors to expense categories (matching pie chart order)
    int paletteIndex = 0;
    final Map<String, Color> categoryColors = <String, Color>{};
    for (final String cat in expenseGroups.keys) {
      categoryColors[cat] =
          _categoryPalette[paletteIndex % _categoryPalette.length];
      paletteIndex++;
    }
    final Map<String, List<Transaction>> transactionsByRowKey =
        _groupTransactionsByRowKey(data.transactions);

    return ValueListenableBuilder<bool>(
      valueListenable: _isEditingNotifier,
      builder: (BuildContext context, bool isEditing, _) {
        return ValueListenableBuilder<Set<String>>(
          valueListenable: _editedKeysNotifier,
          builder: (BuildContext context, Set<String> editedKeys, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: _collapsedCategoriesNotifier,
              builder:
                  (BuildContext context, Set<String> collapsedCategories, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: _inlineEditingKeyNotifier,
                      builder:
                          (BuildContext context, String? inlineEditingKey, _) {
                            return ValueListenableBuilder<Set<String>>(
                              valueListenable: _expandedSubcategoryKeysNotifier,
                              builder:
                                  (
                                    BuildContext context,
                                    Set<String> expandedSubcategoryKeys,
                                    _,
                                  ) {
                                    return Column(
                                      children: <Widget>[
                                        if (incomeGroups
                                            .isNotEmpty) ...<Widget>[
                                          _buildSectionTable(
                                            orgId: orgId,
                                            data: data,
                                            sectionLabel: 'Income',
                                            groups: incomeGroups,
                                            subtotals: subtotals,
                                            isEditing: isEditing,
                                            editedKeys: editedKeys,
                                            collapsedCategories:
                                                collapsedCategories,
                                            categoryColors: categoryColors,
                                            inlineEditingKey: inlineEditingKey,
                                            expandedSubcategoryKeys:
                                                expandedSubcategoryKeys,
                                            transactionsByRowKey:
                                                transactionsByRowKey,
                                          ),
                                          const SizedBox(
                                            height: AppConstants.spacingMd,
                                          ),
                                        ],
                                        if (expenseGroups.isNotEmpty)
                                          _buildSectionTable(
                                            orgId: orgId,
                                            data: data,
                                            sectionLabel: 'Expenses',
                                            groups: expenseGroups,
                                            subtotals: subtotals,
                                            isEditing: isEditing,
                                            editedKeys: editedKeys,
                                            collapsedCategories:
                                                collapsedCategories,
                                            categoryColors: categoryColors,
                                            inlineEditingKey: inlineEditingKey,
                                            expandedSubcategoryKeys:
                                                expandedSubcategoryKeys,
                                            transactionsByRowKey:
                                                transactionsByRowKey,
                                          ),
                                      ],
                                    );
                                  },
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

  Widget _buildSectionTable({
    required String orgId,
    required MonthlyBudgetData data,
    required String sectionLabel,
    required Map<String, List<MonthlyRow>> groups,
    required Map<String, ({double budget, double actual, double business})>
    subtotals,
    required bool isEditing,
    required Set<String> editedKeys,
    required Set<String> collapsedCategories,
    required Map<String, Color> categoryColors,
    required String? inlineEditingKey,
    required Set<String> expandedSubcategoryKeys,
    required Map<String, List<Transaction>> transactionsByRowKey,
  }) {
    final bool isIncomeSection = sectionLabel == 'Income';
    // Darker, more muted colors
    const Color incomeHeader = Color(0xFF1B5E20);
    const Color expenseHeader = Color(0xFF7F1D1D);
    const Color incomeTotalRow = Color(0xFFE8F5E9);
    const Color expenseTotalRow = Color(0xFFFFF1F2);

    final Color headerColor = isIncomeSection ? incomeHeader : expenseHeader;
    final Color totalRowColor = isIncomeSection
        ? incomeTotalRow
        : expenseTotalRow;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          // Section header
          Container(
            color: headerColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  sectionLabel,
                  style: AppTextStyles.pageTitle.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Builder(
                  builder: (BuildContext context) {
                    final List<String> categoryKeys = groups.keys.toList();
                    final bool allCollapsed = categoryKeys.every(
                      (String k) => collapsedCategories.contains(k),
                    );
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: allCollapsed ? 'Expand all' : 'Collapse all',
                      icon: Icon(
                        allCollapsed
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: AppColors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        final Set<String> current = Set<String>.of(
                          _collapsedCategoriesNotifier.value,
                        );
                        if (allCollapsed) {
                          current.removeAll(categoryKeys);
                        } else {
                          current.addAll(categoryKeys);
                        }
                        _collapsedCategoriesNotifier.value = current;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Column headers
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingXs,
            ),
            child: Row(
              children: const <Widget>[
                _DesktopHeaderCell('Subcategory', flex: 3),
                _DesktopHeaderCell('Budget/Actual', flex: 4),
                _DesktopHeaderCell('Personal', flex: 2, alignRight: true),
                _DesktopHeaderCell('Business', flex: 2, alignRight: true),
                _DesktopHeaderCell('Biz%', flex: 1, alignRight: true),
              ],
            ),
          ),
          // Category groups
          ...groups.entries.expand((MapEntry<String, List<MonthlyRow>> entry) {
            final String category = entry.key;
            final List<MonthlyRow> rows = entry.value;
            final ({double budget, double actual, double business}) subtotal =
                subtotals[category] ?? (budget: 0, actual: 0, business: 0);
            final double subtotalPersonal = subtotal.actual - subtotal.business;
            final bool isCollapsed = collapsedCategories.contains(category);

            return <Widget>[
              Container(
                margin: isCollapsed
                    ? const EdgeInsets.only(bottom: AppConstants.spacingXs)
                    : EdgeInsets.zero,
                child: InkWell(
                  onTap: () => _toggleCategory(category),
                  child: Container(
                    decoration: isCollapsed
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                categoryColors[category] ?? AppColors.navy,
                                AppColors.white,
                              ],
                              stops: const <double>[0.0, 0.75],
                            ),
                          )
                        : BoxDecoration(
                            color: categoryColors[category] ?? AppColors.navy,
                          ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingXs,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                isCollapsed
                                    ? Icons.keyboard_arrow_right
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  category,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    color: AppColors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCollapsed)
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: AppConstants.spacingXs,
                              ),
                              child: _BudgetActualBar(
                                budget: subtotal.budget,
                                actual: subtotal.actual,
                                formatCurrency: _formatCurrency,
                                formatBudget: _formatCurrency,
                              ),
                            ),
                          )
                        else
                          const Expanded(flex: 4, child: SizedBox.shrink()),
                        _DesktopBodyCell(
                          _formatCurrency(subtotalPersonal),
                          flex: 2,
                          alignRight: true,
                          fontWeight: FontWeight.w600,
                          color: isCollapsed ? AppColors.text : AppColors.white,
                        ),
                        _DesktopBodyCell(
                          _formatCurrency(subtotal.business),
                          flex: 2,
                          alignRight: true,
                          fontWeight: FontWeight.w600,
                          color: isCollapsed ? AppColors.text : AppColors.white,
                        ),
                        _DesktopBodyCell(
                          '—',
                          flex: 1,
                          alignRight: true,
                          color: isCollapsed ? AppColors.text : AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isCollapsed)
                ...rows.asMap().entries.map((
                  MapEntry<int, MonthlyRow> mappedRow,
                ) {
                  final int index = mappedRow.key;
                  final MonthlyRow row = mappedRow.value;
                  final bool isEdited = editedKeys.contains(row.key);
                  final bool isInlineActive = inlineEditingKey == row.key;
                  final List<Transaction> rowTransactions =
                      transactionsByRowKey[row.key] ?? const <Transaction>[];
                  final bool hasTransactions = rowTransactions.isNotEmpty;
                  final bool isExpanded =
                      !isEditing && expandedSubcategoryKeys.contains(row.key);

                  return Column(
                    children: <Widget>[
                      Container(
                        color: isInlineActive
                            ? AppColors.amberFill
                            : isEdited
                            ? AppColors.amberFill
                            : isIncomeSection
                            ? AppColors.greenFill
                            : (index.isEven
                                  ? AppColors.white
                                  : AppColors.lightGray),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: <Widget>[
                                  // Inline edit / save icon (hidden during global edit mode)
                                  if (!isEditing)
                                    isInlineActive
                                        ? IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 18,
                                              color: AppColors.teal,
                                            ),
                                            tooltip: 'Save',
                                            onPressed: () => _saveInlineRow(
                                              context,
                                              orgId,
                                              data,
                                              row,
                                            ),
                                          )
                                        : IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: inlineEditingKey == null
                                                  ? AppColors.textMuted
                                                  : Colors.transparent,
                                            ),
                                            tooltip: 'Edit budget',
                                            onPressed: inlineEditingKey == null
                                                ? () => _startInlineEdit(
                                                    row,
                                                    orgId,
                                                    data.year,
                                                    data.month,
                                                  )
                                                : null,
                                          ),
                                  if (!isEditing)
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                        minHeight: 24,
                                      ),
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_right,
                                        size: 18,
                                        color: hasTransactions
                                            ? AppColors.textMuted
                                            : AppColors.border,
                                      ),
                                      tooltip: hasTransactions
                                          ? (isExpanded
                                                ? 'Hide transactions'
                                                : 'Show transactions')
                                          : 'No transactions',
                                      onPressed:
                                          hasTransactions && !isInlineActive
                                          ? () => _toggleSubcategoryExpanded(
                                              row.key,
                                            )
                                          : null,
                                    ),
                                  if (!isEditing) const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      row.subcategory,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isInlineActive)
                                    GestureDetector(
                                      onTap: _cancelInlineEdit,
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isEditing)
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  controller: _controllers[row.key],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    prefixText: r'$ ',
                                  ),
                                  onChanged: (_) => _markEdited(row.key),
                                ),
                              )
                            else if (isInlineActive)
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      controller: _inlineController,
                                      autofocus: true,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        prefixText: r'$ ',
                                        hintText: 'Budget',
                                      ),
                                      onSubmitted: (_) => _saveInlineRow(
                                        context,
                                        orgId,
                                        data,
                                        row,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (_lastMonthActual == null)
                                      Text(
                                        'Loading…',
                                        style: AppTextStyles.label.copyWith(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      )
                                    else if (_lastMonthActual! > 0)
                                      GestureDetector(
                                        onTap: () => setState(() {
                                          _inlineController?.text =
                                              _formatBudgetInput(
                                                _lastMonthActual!,
                                              );
                                        }),
                                        child: Text(
                                          'Last month: ${_formatCurrency(_lastMonthActual!)}  — tap to apply',
                                          style: AppTextStyles.label.copyWith(
                                            fontSize: 11,
                                            color: AppColors.teal,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            else
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppConstants.spacingXs,
                                  ),
                                  child: _BudgetActualBar(
                                    budget: row.budget,
                                    actual: row.actual,
                                    formatCurrency: _formatCurrency,
                                    formatBudget: _formatCurrency,
                                  ),
                                ),
                              ),
                            _DesktopBodyCell(
                              _formatCurrency(row.personal),
                              flex: 2,
                              alignRight: true,
                            ),
                            _DesktopBodyCell(
                              _formatCurrency(row.business),
                              flex: 2,
                              alignRight: true,
                            ),
                            if (isInlineActive)
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _inlineBizPctController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    suffixText: '%',
                                  ),
                                  onSubmitted: (_) =>
                                      _saveInlineRow(context, orgId, data, row),
                                ),
                              )
                            else
                              _DesktopBodyCell(
                                '${(row.bizPct * 100).toStringAsFixed(0)}%',
                                flex: 1,
                                alignRight: true,
                              ),
                          ],
                        ),
                      ),
                      if (isExpanded)
                        _buildTransactionSubRows(
                          context,
                          orgId: orgId,
                          transactions: rowTransactions,
                        ),
                    ],
                  );
                }),
              if (!isCollapsed)
                Container(
                  color: totalRowColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  child: Row(
                    children: <Widget>[
                      const _DesktopBodyCell(
                        'Category Total',
                        flex: 3,
                        fontWeight: FontWeight.w700,
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: AppConstants.spacingXs,
                          ),
                          child: _BudgetActualBar(
                            budget: subtotal.budget,
                            actual: subtotal.actual,
                            formatCurrency: _formatCurrency,
                            formatBudget: _formatCurrency,
                          ),
                        ),
                      ),
                      _DesktopBodyCell(
                        _formatCurrency(subtotalPersonal),
                        flex: 2,
                        alignRight: true,
                        fontWeight: FontWeight.w700,
                      ),
                      _DesktopBodyCell(
                        _formatCurrency(subtotal.business),
                        flex: 2,
                        alignRight: true,
                        fontWeight: FontWeight.w700,
                      ),
                      const _DesktopBodyCell(
                        '—',
                        flex: 1,
                        alignRight: true,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildUncategorizedPanel(
    BuildContext context, {
    required String orgId,
    required MonthlyBudgetData data,
    required List<Transaction> transactions,
    required List<Transaction> suggestionHistory,
  }) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                _isUncategorizedExpanded = !_isUncategorizedExpanded;
              });
            },
            child: Container(
              color: const Color(0xFFFFF7E6),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    _isUncategorizedExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18,
                    color: AppColors.text,
                  ),
                  const SizedBox(width: AppConstants.spacingXs),
                  Expanded(
                    child: Text(
                      'Uncategorized Transactions (${transactions.length})',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUncategorizedExpanded) ...<Widget>[
            Container(
              color: AppColors.navy,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingXs,
              ),
              child: const Row(
                children: <Widget>[
                  _DesktopHeaderCell('Date', flex: 2),
                  _DesktopHeaderCell('Merchant', flex: 4),
                  _DesktopHeaderCell(
                    'Original Category / Subcategory',
                    flex: 4,
                  ),
                  _DesktopHeaderCell('Amount', flex: 2, alignRight: true),
                ],
              ),
            ),
            ...transactions.asMap().entries.map((MapEntry<int, Transaction> e) {
              final Transaction transaction = e.value;
              final ({String category, String subcategory})? suggestion =
                  _buildSuggestion(transaction, suggestionHistory);
              final String merchant = transaction.merchant.trim().isEmpty
                  ? '—'
                  : transaction.merchant;
              final String category = transaction.category.trim().isEmpty
                  ? '—'
                  : transaction.category;
              final String subcategory = transaction.subcategory.trim().isEmpty
                  ? '—'
                  : transaction.subcategory;

              return InkWell(
                onTap: () async {
                  await showTransactionForm(
                    context,
                    orgId: orgId,
                    initialTransaction: transaction,
                  );
                  if (!mounted) {
                    return;
                  }
                  ref.invalidate(
                    monthlyBudgetDataProvider(orgId, data.year, data.month),
                  );
                },
                child: Container(
                  color: e.key.isEven ? AppColors.white : AppColors.lightGray,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingXs,
                  ),
                  child: Row(
                    children: <Widget>[
                      _DesktopBodyCell(
                        _transactionDate.format(transaction.date),
                        flex: 2,
                      ),
                      _DesktopBodyCell(merchant, flex: 4),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '$category / $subcategory',
                              style: AppTextStyles.body.copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (suggestion != null)
                              Text(
                                'Suggested: ${suggestion.category} / ${suggestion.subcategory}',
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 11,
                                  color: AppColors.teal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              _formatCurrency(transaction.amount),
                              textAlign: TextAlign.right,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (suggestion != null) ...<Widget>[
                              const SizedBox(width: AppConstants.spacingXs),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 22,
                                  minHeight: 22,
                                ),
                                tooltip: 'Apply suggestion',
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: AppColors.green,
                                ),
                                onPressed: () async {
                                  final ScaffoldMessengerState messenger =
                                      ScaffoldMessenger.of(context);
                                  try {
                                    await ref
                                        .read(
                                          transactionControllerProvider
                                              .notifier,
                                        )
                                        .save(
                                          transaction.copyWith(
                                            category: suggestion.category,
                                            subcategory: suggestion.subcategory,
                                          ),
                                          isEdit: true,
                                        );

                                    if (!mounted) {
                                      return;
                                    }

                                    ref.invalidate(
                                      monthlyBudgetDataProvider(
                                        orgId,
                                        data.year,
                                        data.month,
                                      ),
                                    );

                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Suggested category applied: '
                                          '${suggestion.category} / ${suggestion.subcategory}',
                                        ),
                                      ),
                                    );
                                  } catch (_) {
                                    if (!mounted) {
                                      return;
                                    }
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Unable to apply suggestion.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCharts(MonthlyBudgetData data) {
    double incomeActual = 0;
    double incomeBudget = 0;
    double expenseActual = 0;
    double expenseBudget = 0;
    double businessActual = 0;

    for (final MapEntry<
          String,
          ({double budget, double actual, double business})
        >
        entry
        in data.categorySubtotals.entries) {
      if (isIncome(entry.key)) {
        incomeActual += entry.value.actual;
        incomeBudget += entry.value.budget;
      } else if (!isTransfer(entry.key)) {
        expenseActual += entry.value.actual;
        expenseBudget += entry.value.budget;
        businessActual += entry.value.business;
      }
    }

    final double personalExpense = expenseActual - businessActual;
    final double bizPct = expenseActual > 0
        ? businessActual / expenseActual
        : 0;
    final double personalPct = expenseActual > 0
        ? personalExpense / expenseActual
        : 0;

    // Expense pie: personal spending per category (exclude business portion)
    final List<
      MapEntry<String, ({double budget, double actual, double business})>
    >
    expenseEntries = data.categorySubtotals.entries
        .where(
          (
            MapEntry<String, ({double budget, double actual, double business})>
            e,
          ) => !isIncome(e.key) && !isTransfer(e.key) && e.value.actual > 0,
        )
        .toList(growable: false);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Monthly Overview', style: AppTextStyles.cardTitle),
                    const SizedBox(height: AppConstants.spacingMd),
                    _NetSavingsBar(
                      incomeActual: incomeActual,
                      expenseActual: expenseActual,
                      formatCurrency: _formatCurrency,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _SummaryBar(
                      label: 'Income',
                      actual: incomeActual,
                      budget: incomeBudget,
                      fillColor: AppColors.green,
                      formatCurrency: _formatCurrency,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _SummaryBar(
                      label:
                          'Expenses (personal ${(personalPct * 100).toStringAsFixed(0)}% / business ${(bizPct * 100).toStringAsFixed(0)}%)',
                      actual: expenseActual,
                      budget: expenseBudget,
                      fillColor: expenseActual > expenseBudget
                          ? AppColors.red
                          : expenseBudget > 0 &&
                                expenseActual / expenseBudget >= 0.8
                          ? AppColors.amber
                          : AppColors.teal,
                      formatCurrency: _formatCurrency,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _SummaryBar(
                      label: 'Business Expenses',
                      actual: businessActual,
                      budget: 0,
                      fillColor: const Color(0xFF8E44AD),
                      formatCurrency: _formatCurrency,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Spending by Category',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    if (expenseEntries.isEmpty)
                      const _ChartPlaceholder(message: 'No expense data.')
                    else ...<Widget>[
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            pieTouchData: PieTouchData(enabled: false),
                            sections: expenseEntries
                                .asMap()
                                .entries
                                .map((
                                  MapEntry<
                                    int,
                                    MapEntry<
                                      String,
                                      ({
                                        double budget,
                                        double actual,
                                        double business,
                                      })
                                    >
                                  >
                                  mapped,
                                ) {
                                  // Personal portion only
                                  final double personal =
                                      mapped.value.value.actual -
                                      mapped.value.value.business;
                                  return PieChartSectionData(
                                    value: personal > 0 ? personal : 0,
                                    color:
                                        _categoryPalette[mapped.key %
                                            _categoryPalette.length],
                                    radius: 50,
                                    title: '',
                                  );
                                })
                                .toList(growable: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Wrap(
                        spacing: AppConstants.spacingSm,
                        runSpacing: 4,
                        children: expenseEntries
                            .asMap()
                            .entries
                            .map((
                              MapEntry<
                                int,
                                MapEntry<
                                  String,
                                  ({
                                    double budget,
                                    double actual,
                                    double business,
                                  })
                                >
                              >
                              mapped,
                            ) {
                              final double personal =
                                  mapped.value.value.actual -
                                  mapped.value.value.business;
                              final String pct = expenseActual > 0
                                  ? ' ${(personal / expenseActual * 100).toStringAsFixed(0)}%'
                                  : '';
                              final String amount = _formatCurrency(personal);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color:
                                          _categoryPalette[mapped.key %
                                              _categoryPalette.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${mapped.value.key}$pct · $amount',
                                    style: AppTextStyles.label.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editMobileRowBudget(
    BuildContext context,
    MonthlyRow row,
  ) async {
    final TextEditingController? controller = _controllers[row.key];
    if (controller == null) {
      return;
    }

    final TextEditingController sheetController = TextEditingController(
      text: controller.text,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppConstants.spacingLg,
            right: AppConstants.spacingLg,
            top: AppConstants.spacingLg,
            bottom:
                MediaQuery.viewInsetsOf(sheetContext).bottom +
                AppConstants.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(row.subcategory, style: AppTextStyles.cardTitle),
              const SizedBox(height: AppConstants.spacingSm),
              TextField(
                controller: sheetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Budget',
                  prefixText: r'$ ',
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.text = sheetController.text;
                        _markEdited(row.key);
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    sheetController.dispose();
  }

  void _handleMonthChange(int month) {
    if (month == _selectedMonthNotifier.value) {
      return;
    }

    if (_isEditingNotifier.value) {
      _cancelEditing();
    }
    _expandedSubcategoryKeysNotifier.value = <String>{};
    _collapsedCategoriesNotifier.value = <String>{};
    _isUncategorizedExpanded = true;
    _selectedMonthNotifier.value = month;
  }

  void _toggleCategory(String category) {
    final Set<String> collapsed = Set<String>.of(
      _collapsedCategoriesNotifier.value,
    );
    if (collapsed.contains(category)) {
      collapsed.remove(category);
    } else {
      collapsed.add(category);
    }
    _collapsedCategoriesNotifier.value = collapsed;
  }

  void _toggleSubcategoryExpanded(String rowKey) {
    final Set<String> expanded = Set<String>.of(
      _expandedSubcategoryKeysNotifier.value,
    );
    if (expanded.contains(rowKey)) {
      expanded.remove(rowKey);
    } else {
      expanded.add(rowKey);
    }
    _expandedSubcategoryKeysNotifier.value = expanded;
  }

  void _startEditing(List<MonthlyRow> rows) {
    _disposeControllers();
    _editingRows.clear();
    _expandedSubcategoryKeysNotifier.value = <String>{};

    for (final MonthlyRow row in rows) {
      _editingRows[row.key] = row;
      _controllers[row.key] = TextEditingController(
        text: _formatBudgetInput(row.budget),
      );
    }

    _editedKeysNotifier.value = <String>{};
    _isEditingNotifier.value = true;
  }

  void _copyDefaults() {
    for (final MapEntry<String, MonthlyRow> entry in _editingRows.entries) {
      final TextEditingController? controller = _controllers[entry.key];
      if (controller == null) {
        continue;
      }
      controller.text = _formatBudgetInput(entry.value.globalBudget);
    }

    _editedKeysNotifier.value = Set<String>.from(_editingRows.keys);
  }

  void _cancelEditing() {
    _disposeControllers();
    _editingRows.clear();
    _editedKeysNotifier.value = <String>{};
    _isEditingNotifier.value = false;
  }

  Future<void> _saveMonthBudgets(
    BuildContext context,
    String orgId,
    MonthlyBudgetData data,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final List<BudgetDefault> budgets = _editingRows.values
        .map((MonthlyRow row) {
          final TextEditingController? controller = _controllers[row.key];
          final double amount = _parseBudgetValue(controller?.text);
          return BudgetDefault(
            id: '',
            orgId: orgId,
            category: row.category,
            subcategory: row.subcategory,
            monthlyAmount: amount,
            defaultBizPct: row.defaultBizPct,
            month: DateTime.utc(data.year, data.month, 1),
          );
        })
        .toList(growable: false);

    try {
      await ref
          .read(monthlyControllerProvider.notifier)
          .saveMonthBudgets(orgId, data.year, data.month, budgets);

      messenger.showSnackBar(
        SnackBar(content: Text('✅ ${_monthName(data.month)} budgets saved')),
      );
      _cancelEditing();
    } catch (error) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to save monthly budgets.')),
      );
    }
  }

  Future<void> _clearOverrides(
    BuildContext context,
    String orgId,
    MonthlyBudgetData data,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear Overrides'),
          content: Text(
            'Remove custom budgets for ${_monthName(data.month)}? '
            'This will use your default budgets instead.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    try {
      final DateTime monthStart = DateTime.utc(data.year, data.month, 1);
      final List<BudgetDefault> budgets = data.rows
          .map(
            (MonthlyRow row) => BudgetDefault(
              id: '',
              orgId: orgId,
              category: row.category,
              subcategory: row.subcategory,
              monthlyAmount: row.globalBudget,
              defaultBizPct: row.defaultBizPct,
              month: monthStart,
            ),
          )
          .toList(growable: false);

      await ref
          .read(monthlyControllerProvider.notifier)
          .saveMonthBudgets(orgId, data.year, data.month, budgets);

      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ ${_monthName(data.month)} reset to global defaults'),
        ),
      );
      if (_isEditingNotifier.value) {
        _cancelEditing();
      }
    } catch (error) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to clear month overrides.')),
      );
    }
  }

  void _markEdited(String key) {
    final Set<String> edited = Set<String>.of(_editedKeysNotifier.value)
      ..add(key);
    _editedKeysNotifier.value = edited;
  }

  Future<void> _copyAndSaveDefaults(
    BuildContext context,
    String orgId,
    MonthlyBudgetData data,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final DateTime monthStart = DateTime.utc(data.year, data.month, 1);
      // data.rows already contains the correct category/subcategory names from
      // the categories table and globalBudget from budgets WHERE month IS NULL.
      final List<BudgetDefault> budgets = data.rows
          .map(
            (MonthlyRow row) => BudgetDefault(
              id: '',
              orgId: orgId,
              category: row.category,
              subcategory: row.subcategory,
              monthlyAmount: row.globalBudget,
              defaultBizPct: row.defaultBizPct,
              month: monthStart,
            ),
          )
          .toList(growable: false);

      await ref
          .read(monthlyControllerProvider.notifier)
          .saveMonthBudgets(orgId, data.year, data.month, budgets);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '✅ Global defaults copied to ${_monthName(data.month)}',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to copy defaults.')),
      );
    }
  }

  void _startInlineEdit(MonthlyRow row, String orgId, int year, int month) {
    _inlineController?.dispose();
    _inlineBizPctController?.dispose();
    _inlineController = TextEditingController(
      text: _formatBudgetInput(row.budget),
    );
    _inlineBizPctController = TextEditingController(
      text: (row.defaultBizPct * 100).toStringAsFixed(0),
    );
    _lastMonthActual = null;
    _inlineEditingKeyNotifier.value = row.key;

    // Fetch last month's actual in the background
    final DateTime lastMonth = DateTime.utc(year, month - 1, 1);
    ref
        .read(
          monthlyBudgetDataProvider(
            orgId,
            lastMonth.year,
            lastMonth.month,
          ).future,
        )
        .then((MonthlyBudgetData lastData) {
          final MonthlyRow? lastRow = lastData.rows
              .where(
                (MonthlyRow r) =>
                    r.category == row.category &&
                    r.subcategory == row.subcategory,
              )
              .firstOrNull;
          if (mounted && _inlineEditingKeyNotifier.value == row.key) {
            // Use -1 as sentinel for "loaded but no data"
            setState(
              () => _lastMonthActual = lastRow != null ? lastRow.actual : -1.0,
            );
          }
        })
        .ignore();
  }

  void _cancelInlineEdit() {
    _inlineController?.dispose();
    _inlineBizPctController?.dispose();
    _inlineController = null;
    _inlineBizPctController = null;
    _inlineEditingKeyNotifier.value = null;
  }

  Future<void> _saveInlineRow(
    BuildContext context,
    String orgId,
    MonthlyBudgetData data,
    MonthlyRow row,
  ) async {
    final double amount = _parseBudgetValue(_inlineController?.text);
    final double bizPct =
        (_parseBudgetValue(_inlineBizPctController?.text) / 100).clamp(0, 1);
    final BudgetDefault budget = BudgetDefault(
      id: '',
      orgId: orgId,
      category: row.category,
      subcategory: row.subcategory,
      monthlyAmount: amount,
      defaultBizPct: bizPct,
      month: DateTime.utc(data.year, data.month, 1),
    );

    // Build full list: existing overrides for all rows, replacing this one
    final Map<String, BudgetDefault> existing = <String, BudgetDefault>{
      for (final MonthlyRow r in data.rows)
        if (r.hasCustomBudget)
          r.key: BudgetDefault(
            id: '',
            orgId: orgId,
            category: r.category,
            subcategory: r.subcategory,
            monthlyAmount: r.budget,
            defaultBizPct: r.defaultBizPct,
            month: DateTime.utc(data.year, data.month, 1),
          ),
    };
    existing[row.key] = budget;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      // Save the month override
      await ref
          .read(monthlyControllerProvider.notifier)
          .saveMonthBudgets(
            orgId,
            data.year,
            data.month,
            existing.values.toList(),
          );

      // Also update the global default's defaultBizPct so the transaction form
      // picks it up when this subcategory is selected.
      final SettingsService service = ref.read(settingsServiceProvider);
      final List<BudgetDefault> globalDefaults = await service
          .fetchBudgetDefaults(orgId);
      final BudgetDefault? globalRow = globalDefaults
          .where(
            (BudgetDefault d) =>
                d.category == row.category && d.subcategory == row.subcategory,
          )
          .firstOrNull;
      if (globalRow != null) {
        await service.saveBudgetDefaults(<BudgetDefault>[
          globalRow.copyWith(defaultBizPct: bizPct),
        ]);
        ref.invalidate(budgetDefaultsProvider(orgId));
      }

      messenger.showSnackBar(
        SnackBar(content: Text('✅ ${row.subcategory} budget saved')),
      );
      _cancelInlineEdit();
    } catch (error, stack) {
      debugPrint('_saveInlineRow error: $error\n$stack');
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to save budget.')),
      );
    }
  }

  void _disposeControllers() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  List<Transaction> _filterUncategorizedTransactions(MonthlyBudgetData data) {
    return data.transactions
        .where(
          (Transaction t) =>
              t.category == 'Uncategorized' && t.subcategory == 'Uncategorized',
        )
        .toList(growable: false);
  }

  ({String category, String subcategory})? _buildSuggestion(
    Transaction transaction,
    List<Transaction> allTransactions,
  ) {
    if (transaction.category != 'Uncategorized' ||
        transaction.subcategory != 'Uncategorized') {
      return null;
    }

    final String merchantPrefix = _normalizeMerchant(transaction.merchant);
    if (merchantPrefix.isEmpty) {
      return null;
    }

    final Map<String, int> voteCountByKey = <String, int>{};
    final Map<String, ({String category, String subcategory})> pairByKey =
        <String, ({String category, String subcategory})>{};

    for (final Transaction candidate in allTransactions) {
      if (candidate.category == 'Uncategorized') {
        continue;
      }

      final String candidatePrefix = _normalizeMerchant(candidate.merchant);
      if (candidatePrefix.isEmpty || candidatePrefix != merchantPrefix) {
        continue;
      }

      final String key = '${candidate.category}\u0000${candidate.subcategory}';
      voteCountByKey[key] = (voteCountByKey[key] ?? 0) + 1;
      pairByKey[key] = (
        category: candidate.category,
        subcategory: candidate.subcategory,
      );
    }

    if (voteCountByKey.isEmpty) {
      return null;
    }

    String? winningKey;
    int winningVotes = -1;
    for (final MapEntry<String, int> vote in voteCountByKey.entries) {
      if (vote.value > winningVotes) {
        winningVotes = vote.value;
        winningKey = vote.key;
      }
    }

    if (winningKey == null) {
      return null;
    }

    return pairByKey[winningKey];
  }

  String _transactionKey(Transaction transaction) =>
      '${transaction.category}\u0000${transaction.subcategory}';

  Map<String, List<Transaction>> _groupTransactionsByRowKey(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> grouped =
        <String, List<Transaction>>{};
    for (final Transaction transaction in transactions) {
      final String key = _transactionKey(transaction);
      grouped.putIfAbsent(key, () => <Transaction>[]).add(transaction);
    }
    return grouped;
  }

  Widget _buildTransactionSubRows(
    BuildContext context, {
    required String orgId,
    required List<Transaction> transactions,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.spacingLg,
        right: AppConstants.spacingMd,
        bottom: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(AppConstants.spacingXs),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            color: AppColors.tealLight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSm,
              vertical: 6,
            ),
            child: const Row(
              children: <Widget>[
                _DesktopHeaderCell('Date', flex: 2),
                _DesktopHeaderCell('Merchant', flex: 5),
                _DesktopHeaderCell('Amount', flex: 2, alignRight: true),
                _DesktopHeaderCell('Biz%', flex: 1, alignRight: true),
              ],
            ),
          ),
          ...transactions.asMap().entries.map((
            MapEntry<int, Transaction> entry,
          ) {
            final Transaction transaction = entry.value;
            final String merchant = transaction.merchant.trim().isEmpty
                ? '—'
                : transaction.merchant;

            return InkWell(
              onTap: () => showTransactionForm(
                context,
                orgId: orgId,
                initialTransaction: transaction,
              ),
              child: Container(
                color: entry.key.isEven ? AppColors.white : AppColors.lightGray,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSm,
                  vertical: AppConstants.spacingXs,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        _transactionDate.format(transaction.date),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        merchant,
                        style: AppTextStyles.body.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatCurrency(transaction.amount),
                        textAlign: TextAlign.right,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${(transaction.bizPct * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.label.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, List<MonthlyRow>> _groupRows(List<MonthlyRow> rows) {
    final Map<String, List<MonthlyRow>> grouped = <String, List<MonthlyRow>>{};
    for (final MonthlyRow row in rows) {
      grouped.putIfAbsent(row.category, () => <MonthlyRow>[]).add(row);
    }
    final List<String> sortedCategories = grouped.keys.toList()
      ..sort(compareCategoryOrder);
    return <String, List<MonthlyRow>>{
      for (final String cat in sortedCategories) cat: grouped[cat]!,
    };
  }

  ({double income, double expenses, double net}) _incomeExpenseSummary(
    List<MonthlyRow> rows,
  ) {
    double income = 0;
    double expenses = 0;

    for (final MonthlyRow row in rows) {
      if (row.category == 'Income') {
        income += row.actual;
      } else {
        expenses += row.actual;
      }
    }

    return (income: income, expenses: expenses, net: income - expenses);
  }

  bool _hasTransactions(List<MonthlyRow> rows) {
    return rows.any((MonthlyRow row) => row.actual > 0);
  }

  String _formatCurrency(double amount) {
    return _currency.format(amount);
  }

  String _formatBudget(double amount) {
    if (amount == 0) {
      return '—';
    }
    return _formatCurrency(amount);
  }

  String _formatBudgetInput(double amount) {
    if (amount == 0) {
      return '0';
    }

    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }

  double _parseBudgetValue(String? raw) {
    final String cleaned = (raw ?? '')
        .replaceAll(r'$', '')
        .replaceAll(',', '')
        .trim();
    final double parsed = double.tryParse(cleaned) ?? 0;
    if (parsed < 0) {
      return 0;
    }
    return parsed;
  }

  String _monthName(int month) {
    return DateFormat('MMMM').format(DateTime(0, month));
  }
}

class _NetSavingsBar extends StatelessWidget {
  const _NetSavingsBar({
    required this.incomeActual,
    required this.expenseActual,
    required this.formatCurrency,
  });

  final double incomeActual;
  final double expenseActual;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final double net = incomeActual - expenseActual;
    final bool isPositive = net >= 0;
    final Color barColor = expenseActual > incomeActual
        ? AppColors.red
        : incomeActual > 0 && expenseActual / incomeActual >= 0.9
        ? AppColors.amber
        : AppColors.green;
    // Fill represents expenses as a fraction of income
    final double ratio = incomeActual > 0
        ? (expenseActual / incomeActual).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Net Savings',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${isPositive ? '+' : ''}${formatCurrency(net)}',
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                color: isPositive ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: <Widget>[
              Container(height: 16, color: const Color(0xFFE0E0E0)),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(height: 16, color: barColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          incomeActual > 0
              ? '${formatCurrency(expenseActual)} spent of ${formatCurrency(incomeActual)} income'
              : 'No income recorded',
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.label,
    required this.actual,
    required this.budget,
    required this.fillColor,
    required this.formatCurrency,
  });

  final String label;
  final double actual;
  final double budget;
  final Color fillColor;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final bool hasBudget = budget > 0;
    final double ratio = hasBudget ? (actual / budget).clamp(0, 1) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              hasBudget
                  ? '${formatCurrency(actual)} / ${formatCurrency(budget)}'
                  : formatCurrency(actual),
              style: AppTextStyles.label.copyWith(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: <Widget>[
              Container(height: 16, color: const Color(0xFFE0E0E0)),
              if (hasBudget)
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(height: 16, color: fillColor),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetActualBar extends StatelessWidget {
  const _BudgetActualBar({
    required this.budget,
    required this.actual,
    required this.formatCurrency,
    required this.formatBudget,
  });

  final double budget;
  final double actual;
  final String Function(double) formatCurrency;
  final String Function(double) formatBudget;

  @override
  Widget build(BuildContext context) {
    final bool hasBudget = budget > 0;
    // No budget + any spend = over budget
    final bool isOver = actual > 0 && (!hasBudget || actual > budget);
    final double ratio = hasBudget
        ? (actual / budget).clamp(0, 1)
        : (isOver ? 1.0 : 0);
    final bool isWarning = hasBudget && !isOver && ratio >= 0.8;

    final Color fillColor = isOver
        ? const Color(0xFFEF5350)
        : isWarning
        ? const Color(0xFFFFCA28)
        : const Color(0xFF66BB6A);
    final Color bgColor = isOver
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFE0E0E0);

    // White text on green/red fills, dark text on amber/gray
    final bool useLightText = ratio > 0.4 && (isOver || (!isWarning));
    final Color labelColor = useLightText ? AppColors.white : AppColors.text;
    final Color remainingColor = isOver ? AppColors.white : AppColors.text;

    const double height = 22;
    const double radius = height / 2;
    final double remaining = budget - actual;

    return SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            height: height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          if (ratio > 0)
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  Text(
                    '${formatCurrency(actual)} / ${formatBudget(budget)}',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                  const Spacer(),
                  if (hasBudget || isOver)
                    Text(
                      isOver
                          ? '-${formatCurrency(remaining.abs())}'
                          : formatCurrency(remaining),
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: remainingColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.budget, required this.actual});

  final double budget;
  final double actual;

  @override
  Widget build(BuildContext context) {
    if (budget <= 0) {
      return const SizedBox.shrink();
    }

    final double ratio = actual / budget;
    final double progress = ratio.clamp(0, 1);

    Color color = AppColors.green;
    if (ratio >= 1) {
      color = AppColors.red;
    } else if (ratio >= 0.8) {
      color = AppColors.amber;
    }

    return LinearProgressIndicator(
      value: progress,
      minHeight: 8,
      color: color,
      backgroundColor: AppColors.midGray,
      borderRadius: BorderRadius.circular(6),
    );
  }
}

class _DesktopHeaderCell extends StatelessWidget {
  const _DesktopHeaderCell(
    this.label, {
    required this.flex,
    this.alignRight = false,
  });

  final String label;
  final int flex;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: AppConstants.spacingXs),
        child: Text(
          label,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: AppTextStyles.button.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}

class _DesktopBodyCell extends StatelessWidget {
  const _DesktopBodyCell(
    this.value, {
    required this.flex,
    this.alignRight = false,
    this.fontWeight,
    this.color,
  });

  final String value;
  final int flex;
  final bool alignRight;
  final FontWeight? fontWeight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: AppConstants.spacingXs),
        child: Text(
          value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: AppTextStyles.body.copyWith(
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.textColor,
  });

  final String text;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 280,
        child: Center(
          child: Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }
}
