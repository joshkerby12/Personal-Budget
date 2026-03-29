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

enum _BizFilter { all, personalOnly, businessOnly }

final AutoDisposeStateProvider<String> _searchQueryProvider =
    StateProvider.autoDispose<String>((Ref ref) => '');
final AutoDisposeStateProvider<int?> _monthFilterProvider =
    StateProvider.autoDispose<int?>((Ref ref) => DateTime.now().month);
final AutoDisposeStateProvider<String?> _categoryFilterProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);
final AutoDisposeStateProvider<_BizFilter> _bizFilterProvider =
    StateProvider.autoDispose<_BizFilter>((Ref ref) => _BizFilter.all);

class TransactionsWebScreen extends ConsumerWidget {
  const TransactionsWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(currentOrgIdProvider);
    final String searchQuery = ref.watch(_searchQueryProvider);
    final int? selectedMonth = ref.watch(_monthFilterProvider);
    final String? selectedCategory = ref.watch(_categoryFilterProvider);
    final _BizFilter bizFilter = ref.watch(_bizFilterProvider);

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
              bizFilter: bizFilter,
              searchQuery: searchQuery,
            );

            final ({
              double income,
              double expenses,
              double net,
              double businessTotal,
            })
            summary = calculateTransactionSummary(filtered);

            return Padding(
              padding: const EdgeInsets.all(AppConstants.pagePaddingDesktop),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Transactions', style: AppTextStyles.pageTitle),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  _ToolbarRow(
                    categories: categories,
                    selectedMonth: selectedMonth,
                    selectedCategory: selectedCategory,
                    selectedBizFilter: bizFilter,
                    onSearchChanged: (String value) =>
                        ref.read(_searchQueryProvider.notifier).state = value,
                    onMonthChanged: (int? value) =>
                        ref.read(_monthFilterProvider.notifier).state = value,
                    onCategoryChanged: (String? value) =>
                        ref.read(_categoryFilterProvider.notifier).state =
                            value,
                    onBizFilterChanged: (_BizFilter value) =>
                        ref.read(_bizFilterProvider.notifier).state = value,
                    onAdd: () => showTransactionForm(context, orgId: orgId),
                    onImport: () => showCsvImportFlow(
                      context,
                      ref,
                      isMobile: false,
                      orgId: orgId,
                      existingTransactions: transactions,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  _ImportHistorySection(
                    logsAsync: importLogsAsync,
                    onTapLog: (CsvImportLog log) => showCsvImportDrillDown(
                      context,
                      ref,
                      orgId: orgId,
                      log: log,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  _SummaryBar(
                    transactionCount: filtered.length,
                    income: summary.income,
                    expenses: summary.expenses,
                    net: summary.net,
                    business: summary.businessTotal,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
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
                                _HeaderCell('Date', flex: 2),
                                _HeaderCell('Merchant', flex: 2),
                                _HeaderCell('Description', flex: 2),
                                _HeaderCell('Amount', flex: 1),
                                _HeaderCell('Category', flex: 2),
                                _HeaderCell('Subcategory', flex: 2),
                                _HeaderCell('Personal', flex: 1),
                                _HeaderCell('Business', flex: 1),
                                _HeaderCell('Biz%', flex: 1),
                                _HeaderCell('Receipt', flex: 1),
                                _HeaderCell('Notes', flex: 2),
                                _HeaderCell('Actions', flex: 1),
                              ],
                            ),
                          ),
                          Expanded(
                            child: filtered.isEmpty
                                ? const _DesktopEmptyState()
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final Transaction transaction =
                                              filtered[index];
                                          return _TransactionTableRow(
                                            transaction: transaction,
                                            isEven: index.isEven,
                                            onEdit: () => showTransactionForm(
                                              context,
                                              orgId: orgId,
                                              initialTransaction: transaction,
                                            ),
                                            onDelete: () => _confirmDelete(
                                              context,
                                              ref,
                                              transaction,
                                            ),
                                          );
                                        },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete this transaction?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await ref
          .read(transactionControllerProvider.notifier)
          .delete(transaction.id, transaction.orgId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to delete transaction right now.'),
        ),
      );
    }
  }
}

class _ToolbarRow extends StatelessWidget {
  const _ToolbarRow({
    required this.categories,
    required this.selectedMonth,
    required this.selectedCategory,
    required this.selectedBizFilter,
    required this.onSearchChanged,
    required this.onMonthChanged,
    required this.onCategoryChanged,
    required this.onBizFilterChanged,
    required this.onAdd,
    required this.onImport,
  });

  final List<String> categories;
  final int? selectedMonth;
  final String? selectedCategory;
  final _BizFilter selectedBizFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<_BizFilter> onBizFilterChanged;
  final VoidCallback onAdd;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;

    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search merchant or description',
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<int?>(
            key: ValueKey<int?>(selectedMonth),
            initialValue: selectedMonth,
            decoration: const InputDecoration(labelText: 'Month'),
            items: <DropdownMenuItem<int?>>[
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Months'),
              ),
              ...List<DropdownMenuItem<int?>>.generate(12, (int index) {
                final int month = index + 1;
                final String label = DateFormat(
                  'MMM yyyy',
                ).format(DateTime(currentYear, month, 1));
                return DropdownMenuItem<int?>(value: month, child: Text(label));
              }),
            ],
            onChanged: onMonthChanged,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String?>(
            key: ValueKey<String?>(selectedCategory),
            initialValue: selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All Categories'),
              ),
              ...categories.map(
                (String category) => DropdownMenuItem<String?>(
                  value: category,
                  child: Text(category),
                ),
              ),
            ],
            onChanged: onCategoryChanged,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<_BizFilter>(
            key: ValueKey<_BizFilter>(selectedBizFilter),
            initialValue: selectedBizFilter,
            decoration: const InputDecoration(labelText: 'Filter'),
            items: const <DropdownMenuItem<_BizFilter>>[
              DropdownMenuItem<_BizFilter>(
                value: _BizFilter.all,
                child: Text('All'),
              ),
              DropdownMenuItem<_BizFilter>(
                value: _BizFilter.personalOnly,
                child: Text('Personal Only'),
              ),
              DropdownMenuItem<_BizFilter>(
                value: _BizFilter.businessOnly,
                child: Text('Business Only'),
              ),
            ],
            onChanged: (_BizFilter? value) {
              if (value != null) {
                onBizFilterChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        OutlinedButton.icon(
          onPressed: onImport,
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('Import CSV'),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Transaction'),
        ),
      ],
    );
  }
}

class _ImportHistorySection extends StatelessWidget {
  const _ImportHistorySection({
    required this.logsAsync,
    required this.onTapLog,
  });

  final AsyncValue<List<CsvImportLog>> logsAsync;
  final ValueChanged<CsvImportLog> onTapLog;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('MMM d, yyyy · h:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Import History', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            logsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stackTrace) => const Text(
                'Unable to load import history right now.',
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
                  children: <Widget>[
                    Container(
                      color: AppColors.navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSm,
                        vertical: AppConstants.spacingXs,
                      ),
                      child: const Row(
                        children: <Widget>[
                          _HeaderCell('Institution', flex: 2),
                          _HeaderCell('File', flex: 3),
                          _HeaderCell('Imported', flex: 2),
                          _HeaderCell('Count', flex: 1),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: logs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CsvImportLog log = logs[index];

                          return InkWell(
                            onTap: () => onTapLog(log),
                            child: Container(
                              color: index.isEven
                                  ? AppColors.white
                                  : AppColors.lightGray,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacingSm,
                                vertical: AppConstants.spacingSm,
                              ),
                              child: Row(
                                children: <Widget>[
                                  _BodyCell(value: log.institution, flex: 2),
                                  _BodyCell(value: log.filename, flex: 3),
                                  _BodyCell(
                                    value: dateFormatter.format(log.importedAt),
                                    flex: 2,
                                  ),
                                  _BodyCell(
                                    value: '${log.transactionCount}',
                                    flex: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.transactionCount,
    required this.income,
    required this.expenses,
    required this.net,
    required this.business,
  });

  final int transactionCount;
  final double income;
  final double expenses;
  final double net;
  final double business;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(AppConstants.spacingSm),
      ),
      child: Text(
        '$transactionCount transactions | '
        'Income: ${_formatCurrency(income)} | '
        'Expenses: ${_formatCurrency(expenses)} | '
        'Net: ${_formatCurrency(net)} | '
        'Business: ${_formatCurrency(business)}',
        style: AppTextStyles.body,
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
        style: AppTextStyles.button.copyWith(fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({required this.value, required this.flex, this.style});

  final String value;
  final int flex;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: style ?? AppTextStyles.body,
        maxLines: 2,
      ),
    );
  }
}

class _TransactionTableRow extends StatelessWidget {
  const _TransactionTableRow({
    required this.transaction,
    required this.isEven,
    required this.onEdit,
    required this.onDelete,
  });

  final Transaction transaction;
  final bool isEven;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool income = isIncome(transaction.category);
    final double personal = calculatePersonalAmount(
      transaction.amount,
      transaction.bizPct,
    );
    final double business = calculateBusinessAmount(
      transaction.amount,
      transaction.bizPct,
    );

    return Container(
      color: isEven ? AppColors.white : AppColors.lightGray,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          _BodyCell(
            value: DateFormat('MMM d, yyyy').format(transaction.date),
            flex: 2,
          ),
          _BodyCell(value: transaction.merchant, flex: 2),
          _BodyCell(value: transaction.description ?? '-', flex: 2),
          _BodyCell(
            value: _formatCurrency(transaction.amount),
            flex: 1,
            style: AppTextStyles.body.copyWith(
              color: income ? AppColors.green : AppColors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
          _BodyCell(value: transaction.category, flex: 2),
          _BodyCell(value: transaction.subcategory, flex: 2),
          _BodyCell(value: _formatCurrency(personal), flex: 1),
          _BodyCell(value: _formatCurrency(business), flex: 1),
          _BodyCell(
            value: '${(transaction.bizPct * 100).toStringAsFixed(0)}%',
            flex: 1,
          ),
          _BodyCell(
            value: transaction.receiptId == null ? '-' : 'Linked',
            flex: 1,
          ),
          _BodyCell(value: transaction.notes ?? '-', flex: 2),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.teal,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.red,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopEmptyState extends StatelessWidget {
  const _DesktopEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.receipt_long, size: 42, color: AppColors.textMuted),
          SizedBox(height: AppConstants.spacingSm),
          Text('No transactions found', style: AppTextStyles.cardTitle),
          SizedBox(height: AppConstants.spacingXs),
          Text('Add your first transaction above', style: AppTextStyles.body),
        ],
      ),
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
  required int? selectedMonth,
  required String? selectedCategory,
  required _BizFilter bizFilter,
  required String searchQuery,
}) {
  final int currentYear = DateTime.now().year;
  final String query = searchQuery.trim().toLowerCase();

  return transactions
      .where((Transaction transaction) {
        if (selectedMonth != null &&
            (transaction.date.month != selectedMonth ||
                transaction.date.year != currentYear)) {
          return false;
        }

        if (selectedCategory != null &&
            transaction.category != selectedCategory) {
          return false;
        }

        if (bizFilter == _BizFilter.personalOnly && transaction.bizPct > 0) {
          return false;
        }

        if (bizFilter == _BizFilter.businessOnly && transaction.bizPct <= 0) {
          return false;
        }

        if (query.isNotEmpty) {
          final String merchant = transaction.merchant.toLowerCase();
          final String description = (transaction.description ?? '')
              .toLowerCase();
          if (!merchant.contains(query) && !description.contains(query)) {
            return false;
          }
        }

        return true;
      })
      .toList(growable: false);
}

String _formatCurrency(double value) {
  final NumberFormat formatter = NumberFormat.currency(symbol: r'$');
  return formatter.format(value);
}
