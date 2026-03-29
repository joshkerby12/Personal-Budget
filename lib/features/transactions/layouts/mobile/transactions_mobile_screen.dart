import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/current_org_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../categories/models/category.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../helpers/transaction_calculations.dart';
import '../../models/csv_import_log.dart';
import '../../models/transaction.dart';
import '../../presentation/providers/transaction_provider.dart';
import '../../presentation/widgets/csv_import_flow.dart';
import '../../presentation/widgets/transaction_form.dart';

const Color _businessPurple = Color(0xFF8E44AD);
final AutoDisposeStateProvider<int?> _monthFilterProvider =
    StateProvider.autoDispose<int?>((Ref ref) => DateTime.now().month);
final AutoDisposeStateProvider<String?> _categoryFilterProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);
final AutoDisposeStateProvider<bool> _importHistoryExpandedProvider =
    StateProvider.autoDispose<bool>((Ref ref) => true);

class TransactionsMobileScreen extends ConsumerWidget {
  const TransactionsMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);
    final int? selectedMonth = ref.watch(_monthFilterProvider);
    final String? selectedCategory = ref.watch(_categoryFilterProvider);
    final bool isImportHistoryExpanded = ref.watch(
      _importHistoryExpandedProvider,
    );

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load transactions.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<List<Transaction>> transactionsAsync = ref.watch(
          transactionsProvider(orgId),
        );
        final AsyncValue<List<CsvImportLog>> importLogsAsync = ref.watch(
          csvImportLogsProvider(orgId),
        );
        final AsyncValue<List<Category>> categoriesAsync = ref.watch(
          categoriesProvider,
        );

        return transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load transactions right now.'),
          ),
          data: (List<Transaction> transactions) {
            final List<String> categories = _buildCategoryOptions(
              categoriesAsync.valueOrNull,
              transactions,
            );
            final List<Transaction> filtered = _filterTransactions(
              transactions,
              selectedMonth: selectedMonth,
              selectedCategory: selectedCategory,
            );
            final _MobileSummary summary = _MobileSummary.fromTransactions(
              filtered,
            );

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pagePaddingMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Transactions', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppConstants.spacingMd),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => showCsvImportFlow(
                          context,
                          ref,
                          isMobile: true,
                          orgId: orgId,
                          existingTransactions: transactions,
                        ),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Import CSV'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    _MonthChipRow(
                      selectedMonth: selectedMonth,
                      onSelected: (int? value) =>
                          ref.read(_monthFilterProvider.notifier).state = value,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    _CategoryChipRow(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onSelected: (String? value) =>
                          ref.read(_categoryFilterProvider.notifier).state =
                              value,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        '${filtered.length} transactions | '
                        'Total: ${_formatCurrency(summary.total)} | '
                        'Business: ${_formatCurrency(summary.business)} | '
                        'Personal: ${_formatCurrency(summary.personal)}',
                        style: AppTextStyles.label,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _MobileImportHistoryCard(
                      logsAsync: importLogsAsync,
                      expanded: isImportHistoryExpanded,
                      onToggle: () =>
                          ref
                                  .read(_importHistoryExpandedProvider.notifier)
                                  .state =
                              !isImportHistoryExpanded,
                      onTapLog: (CsvImportLog log) => showCsvImportDrillDown(
                        context,
                        ref,
                        orgId: orgId,
                        log: log,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Expanded(
                      child: filtered.isEmpty
                          ? const _EmptyState()
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(
                                        height: AppConstants.spacingSm,
                                      ),
                              itemBuilder: (BuildContext context, int index) {
                                final Transaction transaction = filtered[index];
                                return _TransactionListItem(
                                  transaction: transaction,
                                  onTap: () => showTransactionForm(
                                    context,
                                    orgId: orgId,
                                    initialTransaction: transaction,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MobileImportHistoryCard extends StatelessWidget {
  const _MobileImportHistoryCard({
    required this.logsAsync,
    required this.expanded,
    required this.onToggle,
    required this.onTapLog,
  });

  final AsyncValue<List<CsvImportLog>> logsAsync;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<CsvImportLog> onTapLog;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('MMM d, yyyy');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                children: <Widget>[
                  Text('Import History', style: AppTextStyles.cardTitle),
                  const Spacer(),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMd,
                0,
                AppConstants.spacingMd,
                AppConstants.spacingMd,
              ),
              child: logsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace stackTrace) => const Text(
                  'Unable to load import history.',
                  style: AppTextStyles.body,
                ),
                data: (List<CsvImportLog> logs) {
                  if (logs.isEmpty) {
                    return Text(
                      'No CSV imports yet.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                    );
                  }

                  return Column(
                    children: logs
                        .map((CsvImportLog log) {
                          return InkWell(
                            onTap: () => onTapLog(log),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.spacingSm,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          log.institution,
                                          style: AppTextStyles.cardTitle
                                              .copyWith(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: AppConstants.spacingXs,
                                        ),
                                        Text(
                                          '${log.filename} · '
                                          '${dateFormatter.format(log.importedAt)}',
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacingSm),
                                  Text(
                                    '${log.transactionCount}',
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthChipRow extends StatelessWidget {
  const _MonthChipRow({required this.selectedMonth, required this.onSelected});

  final int? selectedMonth;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _FilterChip(
            label: 'All',
            selected: selectedMonth == null,
            onTap: () => onSelected(null),
          ),
          for (int month = 1; month <= 12; month++)
            _FilterChip(
              label: DateFormat('MMM').format(DateTime(2000, month, 1)),
              selected: selectedMonth == month,
              onTap: () => onSelected(month),
            ),
        ],
      ),
    );
  }
}

class _CategoryChipRow extends StatelessWidget {
  const _CategoryChipRow({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _FilterChip(
            label: 'All Categories',
            selected: selectedCategory == null,
            onTap: () => onSelected(null),
          ),
          for (final String category in categories)
            _FilterChip(
              label: category,
              selected: selectedCategory == category,
              onTap: () => onSelected(category),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.spacingXs),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.teal,
        labelStyle: AppTextStyles.label.copyWith(
          color: selected ? AppColors.white : AppColors.text,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? AppColors.teal : AppColors.border),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({required this.transaction, required this.onTap});

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool income = isIncome(transaction.category);
    final bool hasBusiness = transaction.bizPct > 0;

    final Color iconColor = hasBusiness
        ? _businessPurple
        : (income ? AppColors.green : AppColors.teal);
    final Color amountColor = income ? AppColors.green : AppColors.red;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  income ? Icons.arrow_downward : Icons.arrow_upward,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      transaction.merchant,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      '${transaction.category} / ${transaction.subcategory}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasBusiness) ...<Widget>[
                      const SizedBox(height: AppConstants.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amberFill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.amber),
                        ),
                        child: Text(
                          'BIZ',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _formatCurrency(transaction.amount),
                    style: AppTextStyles.cardTitle.copyWith(color: amountColor),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    DateFormat('MMM d, yyyy').format(transaction.date),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.receipt_long, size: 40, color: AppColors.textMuted),
          SizedBox(height: AppConstants.spacingSm),
          Text('No transactions found', style: AppTextStyles.cardTitle),
          SizedBox(height: AppConstants.spacingXs),
          Text(
            'Add your first transaction using the + button',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

class _MobileSummary {
  const _MobileSummary({
    required this.total,
    required this.business,
    required this.personal,
  });

  final double total;
  final double business;
  final double personal;

  factory _MobileSummary.fromTransactions(List<Transaction> transactions) {
    final ({double income, double expenses, double net, double businessTotal})
    summary = calculateTransactionSummary(transactions);

    final double total = summary.income + summary.expenses;
    final double personal = (summary.expenses - summary.businessTotal).clamp(
      0,
      double.infinity,
    );

    return _MobileSummary(
      total: total,
      business: summary.businessTotal,
      personal: personal,
    );
  }
}

List<String> _buildCategoryOptions(
  List<Category>? categories,
  List<Transaction> transactions,
) {
  final LinkedHashSet<String> ordered = LinkedHashSet<String>();

  for (final Category category in categories ?? const <Category>[]) {
    ordered.add(category.parentCategory);
  }

  for (final Transaction transaction in transactions) {
    ordered.add(transaction.category);
  }

  return ordered.toList(growable: false);
}

List<Transaction> _filterTransactions(
  List<Transaction> transactions, {
  int? selectedMonth,
  String? selectedCategory,
}) {
  return transactions
      .where((Transaction transaction) {
        if (selectedMonth != null && transaction.date.month != selectedMonth) {
          return false;
        }

        if (selectedCategory != null &&
            transaction.category != selectedCategory) {
          return false;
        }

        return true;
      })
      .toList(growable: false);
}

String _formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat.currency(symbol: r'$');
  return formatter.format(value);
}
