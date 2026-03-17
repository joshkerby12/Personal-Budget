import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/error_view.dart';
import '../../settings/models/budget_default.dart';
import '../../transactions/helpers/transaction_calculations.dart';
import '../presentation/providers/monthly_provider.dart';
import 'month_selector.dart';

class MonthlyBudgetView extends ConsumerStatefulWidget {
  const MonthlyBudgetView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  ConsumerState<MonthlyBudgetView> createState() => _MonthlyBudgetViewState();
}

class _MonthlyBudgetViewState extends ConsumerState<MonthlyBudgetView> {
  final NumberFormat _currency = NumberFormat.currency(symbol: r'$');

  late final ValueNotifier<int> _selectedMonthNotifier;
  final ValueNotifier<bool> _isEditingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<Set<String>> _editedKeysNotifier =
      ValueNotifier<Set<String>>(<String>{});
  final ValueNotifier<Set<String>> _collapsedCategoriesNotifier =
      ValueNotifier<Set<String>>(<String>{});

  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, MonthlyRow> _editingRows = <String, MonthlyRow>{};

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
        ],
        ValueListenableBuilder<bool>(
          valueListenable: _isEditingNotifier,
          builder: (BuildContext context, bool isEditing, _) {
            return _buildToolbar(context, orgId, data, isEditing);
          },
        ),
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
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.amber, size: 18),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    'Total budgeted expenses (\$${_currency.format(data.totalBudgeted).replaceAll(r'$', '')}) exceed '
                    'income for this month (\$${_currency.format(data.monthIncome).replaceAll(r'$', '')}). '
                    'You may be drawing from savings.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.amber, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
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
          _buildMobileCategoryGroups(groupedRows, data.categorySubtotals)
        else ...<Widget>[
          _buildDesktopTable(groupedRows, data.categorySubtotals),
          const SizedBox(height: AppConstants.spacingMd),
          _buildDesktopCharts(data.categorySubtotals),
        ],
      ],
    );

    final Widget wrappedContent = widget.isMobile
        ? SingleChildScrollView(child: content)
        : Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(child: content),
            ),
          );

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

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.spacingSm,
                          ),
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () => _toggleCategory(category),
                                child: Container(
                                  width: double.infinity,
                                  color: isIncome(category) ? AppColors.green : AppColors.navy,
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
            return Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1080),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: AppColors.navy,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        child: Row(
                          children: const <Widget>[
                            _DesktopHeaderCell('Subcategory', flex: 3),
                            _DesktopHeaderCell('Budget', flex: 2),
                            _DesktopHeaderCell('Actual', flex: 2),
                            _DesktopHeaderCell('Remaining', flex: 2),
                            _DesktopHeaderCell('Progress', flex: 3),
                            _DesktopHeaderCell('Personal', flex: 2),
                            _DesktopHeaderCell('Business', flex: 2),
                            _DesktopHeaderCell('Biz%', flex: 1),
                          ],
                        ),
                      ),
                      ...groupedRows.entries.expand((
                        MapEntry<String, List<MonthlyRow>> entry,
                      ) {
                        final String category = entry.key;
                        final List<MonthlyRow> rows = entry.value;
                        final ({double budget, double actual, double business})
                        subtotal =
                            subtotals[category] ??
                            (budget: 0, actual: 0, business: 0);

                        final double subtotalPersonal =
                            subtotal.actual - subtotal.business;
                        final double subtotalRemaining =
                            subtotal.budget - subtotal.actual;

                        return <Widget>[
                          Container(
                            width: double.infinity,
                            color: isIncome(category) ? AppColors.green : AppColors.navy,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingMd,
                              vertical: AppConstants.spacingSm,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    category,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: AppColors.white,
                                    ),
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
                          ...rows.asMap().entries.map((
                            MapEntry<int, MonthlyRow> mappedRow,
                          ) {
                            final int index = mappedRow.key;
                            final MonthlyRow row = mappedRow.value;
                            final bool isEven = index.isEven;
                            final bool isEdited = editedKeys.contains(row.key);

                            return Container(
                              color: isEdited
                                  ? AppColors.amberFill
                                  : isIncome(category)
                                      ? AppColors.greenFill
                                      : (isEven
                                            ? AppColors.white
                                            : AppColors.lightGray),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingMd,
                                vertical: AppConstants.spacingSm,
                              ),
                              child: Row(
                                children: <Widget>[
                                  _DesktopBodyCell(
                                    row.subcategory,
                                    flex: 3,
                                    borderColor: row.hasCustomBudget
                                        ? AppColors.amber
                                        : null,
                                    borderWidth: row.hasCustomBudget ? 3 : 0,
                                  ),
                                  if (isEditing)
                                    Expanded(
                                      flex: 2,
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
                                  else
                                    _DesktopBodyCell(
                                      _formatBudget(row.budget),
                                      flex: 2,
                                      alignRight: true,
                                    ),
                                  _DesktopBodyCell(
                                    _formatCurrency(row.actual),
                                    flex: 2,
                                    alignRight: true,
                                  ),
                                  _DesktopBodyCell(
                                    _formatCurrency(row.remaining),
                                    flex: 2,
                                    alignRight: true,
                                    color: row.remaining >= 0
                                        ? AppColors.green
                                        : AppColors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: row.budget > 0
                                        ? _ProgressBar(
                                            budget: row.budget,
                                            actual: row.actual,
                                          )
                                        : const SizedBox.shrink(),
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
                                  _DesktopBodyCell(
                                    '${(row.bizPct * 100).toStringAsFixed(0)}%',
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
                                const _DesktopBodyCell(
                                  'Category Total',
                                  flex: 3,
                                  fontWeight: FontWeight.w700,
                                ),
                                _DesktopBodyCell(
                                  _formatCurrency(subtotal.budget),
                                  flex: 2,
                                  alignRight: true,
                                  fontWeight: FontWeight.w700,
                                ),
                                _DesktopBodyCell(
                                  _formatCurrency(subtotal.actual),
                                  flex: 2,
                                  alignRight: true,
                                  fontWeight: FontWeight.w700,
                                ),
                                _DesktopBodyCell(
                                  _formatCurrency(subtotalRemaining),
                                  flex: 2,
                                  alignRight: true,
                                  color: subtotalRemaining >= 0
                                      ? AppColors.green
                                      : AppColors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                                Expanded(
                                  flex: 3,
                                  child: subtotal.budget > 0
                                      ? _ProgressBar(
                                          budget: subtotal.budget,
                                          actual: subtotal.actual,
                                        )
                                      : const SizedBox.shrink(),
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopCharts(
    Map<String, ({double budget, double actual, double business})> subtotals,
  ) {
    return Row(
      children: <Widget>[
        Expanded(child: _BudgetVsActualChart(subtotals: subtotals)),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(child: _BusinessBreakdownChart(subtotals: subtotals)),
      ],
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

  void _startEditing(List<MonthlyRow> rows) {
    _disposeControllers();
    _editingRows.clear();

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
      await ref
          .read(monthlyControllerProvider.notifier)
          .clearMonthOverrides(orgId, data.year, data.month);

      messenger.showSnackBar(
        SnackBar(content: Text('${_monthName(data.month)} overrides cleared')),
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

  void _disposeControllers() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
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
  const _DesktopHeaderCell(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label, style: AppTextStyles.button.copyWith(fontSize: 13)),
    );
  }
}

class _DesktopBodyCell extends StatelessWidget {
  const _DesktopBodyCell(
    this.value, {
    required this.flex,
    this.alignRight = false,
    this.color,
    this.fontWeight,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String value;
  final int flex;
  final bool alignRight;
  final Color? color;
  final FontWeight? fontWeight;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.only(
          left: borderWidth > 0 ? AppConstants.spacingSm : 0,
          right: AppConstants.spacingXs,
        ),
        decoration: borderWidth > 0
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: borderColor ?? AppColors.border,
                    width: borderWidth,
                  ),
                ),
              )
            : null,
        child: Text(
          value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: fontWeight,
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

class _BudgetVsActualChart extends StatelessWidget {
  const _BudgetVsActualChart({required this.subtotals});

  final Map<String, ({double budget, double actual, double business})>
  subtotals;

  @override
  Widget build(BuildContext context) {
    final List<
      MapEntry<String, ({double budget, double actual, double business})>
    >
    entries = subtotals.entries.toList(growable: false);

    if (entries.isEmpty) {
      return const _ChartPlaceholder(
        message: 'No category data for this month.',
      );
    }

    double maxValue = 0;
    for (final MapEntry<
          String,
          ({double budget, double actual, double business})
        >
        entry
        in entries) {
      maxValue = math.max(
        maxValue,
        math.max(entry.value.budget, entry.value.actual),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Budget vs Actual by Category',
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            SizedBox(
              height: 260,
              child: RotatedBox(
                quarterTurns: 1,
                child: BarChart(
                  BarChartData(
                    maxY: maxValue == 0 ? 100 : maxValue * 1.2,
                    barTouchData: BarTouchData(enabled: false),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 56,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final int index = value.toInt();
                            if (index < 0 || index >= entries.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  entries[index].key,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.label,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: entries
                        .asMap()
                        .entries
                        .map((
                          MapEntry<
                            int,
                            MapEntry<
                              String,
                              ({double budget, double actual, double business})
                            >
                          >
                          mapped,
                        ) {
                          final int index = mapped.key;
                          final ({
                            double budget,
                            double actual,
                            double business,
                          })
                          value = mapped.value.value;
                          return BarChartGroupData(
                            x: index,
                            barsSpace: 6,
                            barRods: <BarChartRodData>[
                              BarChartRodData(
                                toY: value.budget,
                                width: 10,
                                color: AppColors.teal,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              BarChartRodData(
                                toY: value.actual,
                                width: 10,
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessBreakdownChart extends StatelessWidget {
  const _BusinessBreakdownChart({required this.subtotals});

  final Map<String, ({double budget, double actual, double business})>
  subtotals;

  static const List<Color> _palette = <Color>[
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

  @override
  Widget build(BuildContext context) {
    final List<
      MapEntry<String, ({double budget, double actual, double business})>
    >
    entries = subtotals.entries
        .where(
          (
            MapEntry<String, ({double budget, double actual, double business})>
            entry,
          ) => entry.value.business > 0,
        )
        .toList(growable: false);

    if (entries.isEmpty) {
      return const _ChartPlaceholder(
        message: 'No business expenses for this month.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Business Breakdown', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 52,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: entries
                      .asMap()
                      .entries
                      .map((
                        MapEntry<
                          int,
                          MapEntry<
                            String,
                            ({double budget, double actual, double business})
                          >
                        >
                        mapped,
                      ) {
                        final int index = mapped.key;
                        final MapEntry<
                          String,
                          ({double budget, double actual, double business})
                        >
                        entry = mapped.value;
                        return PieChartSectionData(
                          value: entry.value.business,
                          color: _palette[index % _palette.length],
                          radius: 56,
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
              runSpacing: AppConstants.spacingSm,
              children: entries
                  .asMap()
                  .entries
                  .map((
                    MapEntry<
                      int,
                      MapEntry<
                        String,
                        ({double budget, double actual, double business})
                      >
                    >
                    mapped,
                  ) {
                    final int index = mapped.key;
                    final MapEntry<
                      String,
                      ({double budget, double actual, double business})
                    >
                    entry = mapped.value;
                    final Color color = _palette[index % _palette.length];
                    return _LegendItem(
                      color: color,
                      label:
                          '${entry.key}: ${NumberFormat.currency(symbol: r'$').format(entry.value.business)}',
                    );
                  })
                  .toList(growable: false),
            ),
          ],
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

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppConstants.spacingXs),
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.text)),
      ],
    );
  }
}
