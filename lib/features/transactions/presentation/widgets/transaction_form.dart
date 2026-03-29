import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/models/category.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../receipts/models/receipt.dart';
import '../../../receipts/presentation/providers/receipt_provider.dart';
import '../../../receipts/presentation/widgets/receipt_detail_sheet.dart';
import '../../../settings/models/budget_default.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../mileage/models/mileage_trip.dart';
import '../../../mileage/presentation/providers/mileage_provider.dart';
import '../../helpers/transaction_calculations.dart';
import '../../models/transaction.dart';
import '../../../teller/models/teller_enrollment.dart';
import '../../../teller/presentation/providers/teller_provider.dart';
import '../providers/transaction_provider.dart';

final Uuid _uuid = const Uuid();

String _normalizeMerchant(String merchant) {
  final String upper = merchant.toUpperCase();
  final String stripped = upper.replaceAll(RegExp(r'[^A-Z ]'), '');
  final List<String> tokens = stripped
      .split(' ')
      .where((String token) => token.isNotEmpty)
      .toList();
  return tokens.take(4).join(' ');
}

Future<void> showTransactionForm(
  BuildContext context, {
  required String orgId,
  Transaction? initialTransaction,
  String? initialCategory,
  String? initialSubcategory,
}) async {
  final bool isMobile =
      MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;

  if (isMobile) {
    await showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return TransactionForm(
          orgId: orgId,
          initialTransaction: initialTransaction,
          initialCategory: initialCategory,
          initialSubcategory: initialSubcategory,
          onClose: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.85,
          ),
          child: TransactionForm(
            orgId: orgId,
            initialTransaction: initialTransaction,
            initialCategory: initialCategory,
            initialSubcategory: initialSubcategory,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      );
    },
  );
}

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({
    super.key,
    required this.orgId,
    this.initialTransaction,
    this.initialCategory,
    this.initialSubcategory,
    required this.onClose,
  });

  final String orgId;
  final Transaction? initialTransaction;
  final String? initialCategory;
  final String? initialSubcategory;
  final VoidCallback onClose;

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _dateController;
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _bizPctController;
  late final TextEditingController _notesController;

  late final ValueNotifier<DateTime> _selectedDateNotifier;
  late final ValueNotifier<String?> _selectedCategoryNotifier;
  late final ValueNotifier<String?> _selectedSubcategoryNotifier;
  late final ValueNotifier<bool> _isSplitNotifier;
  late final ValueNotifier<String?> _attachedReceiptIdNotifier;
  late final ValueNotifier<String?> _attachedReceiptFilenameNotifier;
  late final TextEditingController _milesController;
  late final ValueNotifier<bool> _roundTripNotifier;

  late final bool _isEdit;
  bool _hasManualBizPctOverride = false;
  late bool _allowBlankCategorySelectionForUncategorized;
  bool _hasAppliedSuggestion = false;
  bool _hasManualCategoryChoice = false;

  @override
  void initState() {
    super.initState();
    final Transaction? transaction = widget.initialTransaction;
    _isEdit = transaction != null;
    final bool isUncategorizedTransaction =
        transaction?.category == 'Uncategorized' &&
        transaction?.subcategory == 'Uncategorized';

    final String? seededCategory =
        widget.initialCategory ??
        (isUncategorizedTransaction ? null : transaction?.category);
    final String? seededSubcategory =
        widget.initialSubcategory ??
        (isUncategorizedTransaction ? null : transaction?.subcategory);
    _allowBlankCategorySelectionForUncategorized =
        isUncategorizedTransaction &&
        widget.initialCategory == null &&
        widget.initialSubcategory == null;
    _hasAppliedSuggestion =
        widget.initialCategory != null || widget.initialSubcategory != null;

    final DateTime date = transaction?.date ?? DateTime.now();
    _selectedDateNotifier = ValueNotifier<DateTime>(date);
    _selectedCategoryNotifier = ValueNotifier<String?>(seededCategory);
    _selectedSubcategoryNotifier = ValueNotifier<String?>(seededSubcategory);
    _isSplitNotifier = ValueNotifier<bool>(transaction?.isSplit ?? false);
    _attachedReceiptIdNotifier = ValueNotifier<String?>(null);
    _attachedReceiptFilenameNotifier = ValueNotifier<String?>(null);
    _milesController = TextEditingController();
    _roundTripNotifier = ValueNotifier<bool>(false);

    _dateController = TextEditingController(text: _formatDate(date));
    _amountController = TextEditingController(
      text: transaction?.amount.toStringAsFixed(2) ?? '',
    );
    _merchantController = TextEditingController(
      text: transaction?.merchant ?? '',
    );
    _descriptionController = TextEditingController(
      text: transaction?.description ?? '',
    );
    _bizPctController = TextEditingController(
      text: ((transaction?.bizPct ?? 0) * 100).toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: transaction?.notes ?? '');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _bizPctController.dispose();
    _notesController.dispose();
    _selectedDateNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    _selectedSubcategoryNotifier.dispose();
    _isSplitNotifier.dispose();
    _attachedReceiptIdNotifier.dispose();
    _attachedReceiptFilenameNotifier.dispose();
    _milesController.dispose();
    _roundTripNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitting = ref
        .watch(transactionControllerProvider)
        .isLoading;
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      categoriesProvider,
    );
    final AsyncValue<List<BudgetDefault>> budgetsAsync = ref.watch(
      budgetDefaultsProvider(widget.orgId),
    );
    final AsyncValue<List<Receipt>> receiptsAsync = ref.watch(
      receiptsProvider(widget.orgId),
    );
    final AsyncValue<List<TellerEnrollment>> tellerEnrollmentsAsync = ref.watch(
      tellerEnrollmentsProvider(widget.orgId),
    );
    final bool isInitialUncategorized =
        widget.initialTransaction?.category == 'Uncategorized' &&
        widget.initialTransaction?.subcategory == 'Uncategorized';
    final AsyncValue<List<Transaction>> suggestionHistoryAsync =
        isInitialUncategorized
        ? ref.watch(recentCategorizedTransactionsProvider(widget.orgId))
        : const AsyncData<List<Transaction>>(<Transaction>[]);
    final bool isReceiptBusy = ref.watch(receiptControllerProvider).isLoading;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppConstants.spacingLg,
          right: AppConstants.spacingLg,
          top: AppConstants.spacingLg,
          bottom:
              MediaQuery.viewInsetsOf(context).bottom + AppConstants.spacingLg,
        ),
        child: categoriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppConstants.spacingLg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object error, StackTrace stackTrace) => _ErrorState(
            message: 'Unable to load categories right now.',
            onClose: widget.onClose,
          ),
          data: (List<Category> categories) => budgetsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppConstants.spacingLg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stackTrace) => _ErrorState(
              message: 'Unable to load budget defaults right now.',
              onClose: widget.onClose,
            ),
            data: (List<BudgetDefault> defaults) {
              final _CategoryData categoryData = _CategoryData.fromCategories(
                categories,
              );
              final ({String category, String subcategory})? suggestion =
                  _buildSuggestion(
                    widget.initialTransaction,
                    suggestionHistoryAsync.valueOrNull ?? const <Transaction>[],
                  );
              _applySuggestionIfNeeded(suggestion, defaults);
              _syncSelection(categoryData, defaults);
              final Widget sourceLabel = _buildSourceLabel(
                tellerEnrollmentsAsync,
              );
              final bool hasSourceLabel = sourceLabel is! SizedBox;

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      _isEdit ? 'Edit Transaction' : 'Add Transaction',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    sourceLabel,
                    if (hasSourceLabel)
                      const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Date'),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Date is required.'
                          : null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Total Amount',
                        prefixText: r'$ ',
                      ),
                      validator: (String? value) {
                        final double? amount = _parseAmount(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter an amount greater than zero.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _merchantController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Merchant/Payee',
                      ),
                      validator: (String? value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Merchant/Payee is required.'
                          : null,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedCategoryNotifier,
                      builder: (BuildContext context, String? category, _) {
                        return DropdownButtonFormField<String>(
                          key: ValueKey<String?>(category),
                          initialValue: category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          hint: const Text('Select category'),
                          items: categoryData.parentCategories
                              .map(
                                (String parent) => DropdownMenuItem<String>(
                                  value: parent,
                                  child: Text(parent),
                                ),
                              )
                              .toList(growable: false),
                          validator: (String? value) =>
                              value == null ? 'Category is required.' : null,
                          onChanged: (String? value) {
                            _selectedCategoryNotifier.value = value;
                            _allowBlankCategorySelectionForUncategorized =
                                false;
                            _hasManualCategoryChoice = true;
                            _selectedSubcategoryNotifier.value = null;

                            final List<String> subcategories =
                                categoryData.subcategoriesByParent[value] ??
                                const <String>[];
                            if (subcategories.isEmpty) {
                              _maybeApplyDefaultBizPct(defaults);
                              return;
                            }
                            final bool isMobile =
                                MediaQuery.sizeOf(context).width <
                                AppConstants.mobileBreakpoint;
                            if (isMobile) {
                              _autoOpenSubcategoryPicker(
                                context,
                                subcategories,
                                defaults,
                              );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedCategoryNotifier,
                      builder: (BuildContext context, String? category, _) {
                        final List<String> subcategories =
                            categoryData.subcategoriesByParent[category] ??
                            const <String>[];
                        return ValueListenableBuilder<String?>(
                          valueListenable: _selectedSubcategoryNotifier,
                          builder:
                              (
                                BuildContext context,
                                String? subcategory,
                                Widget? child,
                              ) {
                                return DropdownButtonFormField<String>(
                                  key: ValueKey<String?>(subcategory),
                                  initialValue: subcategory,
                                  decoration: const InputDecoration(
                                    labelText: 'Subcategory',
                                  ),
                                  hint: const Text('Select subcategory'),
                                  items: subcategories
                                      .map(
                                        (String value) =>
                                            DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            ),
                                      )
                                      .toList(growable: false),
                                  validator: (String? value) => value == null
                                      ? 'Subcategory is required.'
                                      : null,
                                  onChanged: (String? value) {
                                    _hasManualCategoryChoice = true;
                                    _selectedSubcategoryNotifier.value = value;
                                    _maybeApplyDefaultBizPct(defaults);
                                  },
                                );
                              },
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextFormField(
                      controller: _bizPctController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Business %',
                        suffixText: '%',
                      ),
                      onChanged: (_) => _hasManualBizPctOverride = true,
                      validator: (String? value) {
                        final double? bizPct = _parseNumber(value);
                        if (bizPct == null || bizPct < 0 || bizPct > 100) {
                          return 'Business % must be between 0 and 100.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSplitNotifier,
                      builder: (BuildContext context, bool isSplit, _) {
                        return DropdownButtonFormField<bool>(
                          key: ValueKey<bool>(isSplit),
                          initialValue: isSplit,
                          decoration: const InputDecoration(
                            labelText: 'Split Transaction?',
                          ),
                          items: const <DropdownMenuItem<bool>>[
                            DropdownMenuItem<bool>(
                              value: false,
                              child: Text('No'),
                            ),
                            DropdownMenuItem<bool>(
                              value: true,
                              child: Text('Yes'),
                            ),
                          ],
                          onChanged: (bool? value) {
                            if (value != null) {
                              _isSplitNotifier.value = value;
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedCategoryNotifier,
                      builder: (BuildContext context, String? category, _) {
                        final bool showMiles =
                            category == 'Business' || category == 'Healthcare';
                        if (!showMiles) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextFormField(
                              controller: _milesController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Miles driven (optional)',
                                suffixText: 'mi',
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                            ValueListenableBuilder<bool>(
                              valueListenable: _roundTripNotifier,
                              builder:
                                  (BuildContext context, bool isRoundTrip, _) {
                                    return DropdownButtonFormField<bool>(
                                      key: ValueKey<bool>(isRoundTrip),
                                      initialValue: isRoundTrip,
                                      decoration: const InputDecoration(
                                        labelText: 'Round trip?',
                                      ),
                                      items: const <DropdownMenuItem<bool>>[
                                        DropdownMenuItem<bool>(
                                          value: false,
                                          child: Text('No'),
                                        ),
                                        DropdownMenuItem<bool>(
                                          value: true,
                                          child: Text('Yes'),
                                        ),
                                      ],
                                      onChanged: (bool? value) {
                                        if (value != null) {
                                          _roundTripNotifier.value = value;
                                        }
                                      },
                                    );
                                  },
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                          ],
                        );
                      },
                    ),
                    TextFormField(
                      controller: _notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    _SplitPreview(
                      amountController: _amountController,
                      bizPctController: _bizPctController,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    ValueListenableBuilder<String?>(
                      valueListenable: _attachedReceiptIdNotifier,
                      builder:
                          (
                            BuildContext context,
                            String? attachedReceiptId,
                            Widget? child,
                          ) {
                            final Transaction? existing =
                                widget.initialTransaction;
                            final bool hasExistingReceipt =
                                _isEdit && existing?.receiptId != null;

                            if (hasExistingReceipt) {
                              return OutlinedButton.icon(
                                onPressed: isSubmitting || isReceiptBusy
                                    ? null
                                    : () => _viewExistingReceipt(
                                        receiptsAsync,
                                        existing!.receiptId!,
                                      ),
                                icon: const Icon(Icons.attach_file),
                                label: const Text('View Receipt'),
                              );
                            }

                            return OutlinedButton.icon(
                              onPressed: isSubmitting || isReceiptBusy
                                  ? null
                                  : _attachReceipt,
                              icon: const Icon(Icons.attach_file),
                              label: Text(
                                attachedReceiptId == null
                                    ? 'Attach Receipt'
                                    : 'Replace Receipt',
                              ),
                            );
                          },
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: _attachedReceiptFilenameNotifier,
                      builder:
                          (
                            BuildContext context,
                            String? attachedFilename,
                            Widget? child,
                          ) {
                            if (attachedFilename == null ||
                                attachedFilename.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppConstants.spacingXs,
                              ),
                              child: Text(
                                '$attachedFilename ✓',
                                style: AppTextStyles.label,
                              ),
                            );
                          },
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting ? null : widget.onClose,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _save,
                            child: Text(
                              _isEdit
                                  ? 'Update Transaction'
                                  : 'Save Transaction',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isEdit) ...<Widget>[
                      const SizedBox(height: AppConstants.spacingSm),
                      TextButton(
                        onPressed: isSubmitting ? null : _delete,
                        child: const Text(
                          'Delete Transaction',
                          style: TextStyle(color: AppColors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _syncSelection(
    _CategoryData categoryData,
    List<BudgetDefault> defaults,
  ) {
    if (categoryData.parentCategories.isEmpty) {
      _selectedCategoryNotifier.value = null;
      _selectedSubcategoryNotifier.value = null;
      return;
    }

    String? selectedCategory = _selectedCategoryNotifier.value;
    if (_allowBlankCategorySelectionForUncategorized &&
        selectedCategory == null) {
      _selectedSubcategoryNotifier.value = null;
      return;
    }
    if (selectedCategory == null ||
        !categoryData.parentCategories.contains(selectedCategory)) {
      selectedCategory = categoryData.parentCategories.first;
      _selectedCategoryNotifier.value = selectedCategory;
    }

    final List<String> subcategories =
        categoryData.subcategoriesByParent[selectedCategory] ??
        const <String>[];
    if (subcategories.isEmpty) {
      _selectedSubcategoryNotifier.value = null;
      return;
    }

    final String? selectedSubcategory = _selectedSubcategoryNotifier.value;
    if (selectedSubcategory == null ||
        !subcategories.contains(selectedSubcategory)) {
      _selectedSubcategoryNotifier.value = subcategories.first;
    }
    _maybeApplyDefaultBizPct(defaults);
  }

  ({String category, String subcategory})? _buildSuggestion(
    Transaction? transaction,
    List<Transaction> history,
  ) {
    if (transaction == null ||
        transaction.category != 'Uncategorized' ||
        transaction.subcategory != 'Uncategorized') {
      return null;
    }

    final String merchantPrefix = _normalizeMerchant(transaction.merchant);
    if (merchantPrefix.isEmpty) {
      return null;
    }

    final Map<String, int> votes = <String, int>{};
    final Map<String, ({String category, String subcategory})> pairByKey =
        <String, ({String category, String subcategory})>{};

    for (final Transaction candidate in history) {
      if (candidate.category == 'Uncategorized') {
        continue;
      }

      final String candidatePrefix = _normalizeMerchant(candidate.merchant);
      if (candidatePrefix.isEmpty || candidatePrefix != merchantPrefix) {
        continue;
      }

      final String key = '${candidate.category}\u0000${candidate.subcategory}';
      votes[key] = (votes[key] ?? 0) + 1;
      pairByKey[key] = (
        category: candidate.category,
        subcategory: candidate.subcategory,
      );
    }

    if (votes.isEmpty) {
      return null;
    }

    String? winner;
    int winnerVotes = -1;
    for (final MapEntry<String, int> entry in votes.entries) {
      if (entry.value > winnerVotes) {
        winnerVotes = entry.value;
        winner = entry.key;
      }
    }
    if (winner == null) {
      return null;
    }

    return pairByKey[winner];
  }

  void _applySuggestionIfNeeded(
    ({String category, String subcategory})? suggestion,
    List<BudgetDefault> defaults,
  ) {
    if (_hasAppliedSuggestion ||
        _hasManualCategoryChoice ||
        suggestion == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasAppliedSuggestion || _hasManualCategoryChoice) {
        return;
      }
      _selectedCategoryNotifier.value = suggestion.category;
      _selectedSubcategoryNotifier.value = suggestion.subcategory;
      _allowBlankCategorySelectionForUncategorized = false;
      _hasAppliedSuggestion = true;
      _maybeApplyDefaultBizPct(defaults);
    });
  }

  Future<void> _autoOpenSubcategoryPicker(
    BuildContext context,
    List<String> options,
    List<BudgetDefault> defaults,
  ) async {
    if (options.isEmpty) {
      return;
    }
    final bool isMobile =
        MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    String? selected;

    if (isMobile) {
      selected = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext sheetContext) {
          return SafeArea(
            top: false,
            child: ListView(
              shrinkWrap: true,
              children: options
                  .map(
                    (String option) => ListTile(
                      title: Text(option),
                      onTap: () => Navigator.of(sheetContext).pop(option),
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        },
      );
    } else {
      selected = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Choose subcategory'),
            content: SizedBox(
              width: 360,
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map(
                      (String option) => ListTile(
                        title: Text(option),
                        onTap: () => Navigator.of(dialogContext).pop(option),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          );
        },
      );
    }

    if (selected == null || !mounted) {
      return;
    }
    _selectedSubcategoryNotifier.value = selected;
    _maybeApplyDefaultBizPct(defaults);
  }

  Widget _buildSourceLabel(
    AsyncValue<List<TellerEnrollment>> enrollmentsAsync,
  ) {
    final Transaction? initial = widget.initialTransaction;
    if (!_isEdit || initial == null || initial.source == 'manual') {
      return const SizedBox.shrink();
    }

    final List<TellerEnrollment> enrollments =
        enrollmentsAsync.valueOrNull ?? const <TellerEnrollment>[];
    final TellerEnrollment? enrollment = enrollments.isNotEmpty
        ? enrollments.first
        : null;
    final String label = enrollment == null
        ? 'Imported from connected bank account'
        : '${enrollment.institutionName} ${enrollment.accountName} '
              '••${enrollment.accountLastFour ?? '----'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.spacingXs),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.label.copyWith(fontSize: 12)),
    );
  }

  void _maybeApplyDefaultBizPct(List<BudgetDefault> defaults) {
    if (_hasManualBizPctOverride) {
      return;
    }

    final String? category = _selectedCategoryNotifier.value;
    final String? subcategory = _selectedSubcategoryNotifier.value;
    if (category == null || subcategory == null) {
      return;
    }

    BudgetDefault? match;
    for (final BudgetDefault row in defaults) {
      if (row.category == category && row.subcategory == subcategory) {
        match = row;
        break;
      }
    }

    if (match == null) {
      _bizPctController.text = '0';
      return;
    }

    _bizPctController.text = (match.defaultBizPct * 100).toStringAsFixed(0);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNotifier.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    _selectedDateNotifier.value = picked;
    _dateController.text = _formatDate(picked);
  }

  Future<void> _save() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? category = _selectedCategoryNotifier.value;
    final String? subcategory = _selectedSubcategoryNotifier.value;
    if (category == null || subcategory == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Category and subcategory are required.')),
      );
      return;
    }

    final double? amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than zero.'),
        ),
      );
      return;
    }

    final double bizPctValue =
        ((_parseNumber(_bizPctController.text) ?? 0) / 100).clamp(0, 1);
    final String? attachedReceiptId = _attachedReceiptIdNotifier.value;

    final Transaction? initialTransaction = widget.initialTransaction;
    final String? userId = ref
        .read(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    if (userId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('You must be signed in to save.')),
      );
      return;
    }

    final Transaction transaction = Transaction(
      id: initialTransaction?.id ?? _uuid.v4(),
      orgId: widget.orgId,
      createdBy: initialTransaction?.createdBy ?? userId,
      date: _selectedDateNotifier.value,
      amount: amount,
      merchant: _merchantController.text.trim(),
      description: _emptyToNull(_descriptionController.text),
      category: category,
      subcategory: subcategory,
      bizPct: bizPctValue,
      isSplit: _isSplitNotifier.value,
      receiptId: attachedReceiptId ?? initialTransaction?.receiptId,
      notes: _emptyToNull(_notesController.text),
      source: initialTransaction?.source ?? 'manual',
      tellerTransactionId: initialTransaction?.tellerTransactionId,
      createdAt: initialTransaction?.createdAt ?? DateTime.now(),
    );

    try {
      await ref
          .read(transactionControllerProvider.notifier)
          .save(transaction, isEdit: _isEdit);

      if (attachedReceiptId != null) {
        await ref
            .read(receiptControllerProvider.notifier)
            .linkToTransaction(attachedReceiptId, transaction.id);
      }

      final double? miles = double.tryParse(_milesController.text.trim());
      final String? cat = _selectedCategoryNotifier.value;
      if (miles != null &&
          miles > 0 &&
          (cat == 'Business' || cat == 'Healthcare')) {
        final MileageTrip trip = MileageTrip(
          id: _uuid.v4(),
          orgId: widget.orgId,
          createdBy: userId,
          date: _selectedDateNotifier.value,
          purpose: _merchantController.text.trim(),
          fromAddress: '',
          toAddress: '',
          oneWayMiles: miles,
          isRoundTrip: _roundTripNotifier.value,
          bizPct: bizPctValue,
          category: cat == 'Business' ? 'Business - Other' : 'Healthcare',
          createdAt: DateTime.now(),
        );
        await ref
            .read(mileageControllerProvider.notifier)
            .saveTrip(trip, isEdit: false);
      }

      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Transaction updated' : 'Transaction saved'),
        ),
      );
      widget.onClose();
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to save transaction right now.')),
      );
    }
  }

  Future<void> _attachReceipt() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final Receipt? receipt = await ref
          .read(receiptControllerProvider.notifier)
          .pickAndUpload(widget.orgId);
      if (receipt == null) {
        return;
      }
      _attachedReceiptIdNotifier.value = receipt.id;
      _attachedReceiptFilenameNotifier.value = receipt.filename;
      messenger.showSnackBar(
        SnackBar(content: Text('Attached ${receipt.filename}')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('StateError: ', '')),
        ),
      );
    }
  }

  Future<void> _viewExistingReceipt(
    AsyncValue<List<Receipt>> receiptsAsync,
    String receiptId,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (receiptsAsync.isLoading) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Loading receipt details...')),
      );
      return;
    }

    if (receiptsAsync.hasError) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to load receipt details right now.'),
        ),
      );
      return;
    }

    Receipt? receipt;
    for (final Receipt item in receiptsAsync.valueOrNull ?? const <Receipt>[]) {
      if (item.id == receiptId) {
        receipt = item;
        break;
      }
    }

    if (receipt == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('The linked receipt could not be found.')),
      );
      return;
    }

    await showReceiptDetailSheet(
      context,
      orgId: widget.orgId,
      receipt: receipt,
    );
  }

  Future<void> _delete() async {
    final Transaction? transaction = widget.initialTransaction;
    if (transaction == null) {
      return;
    }

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
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
      widget.onClose();
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to delete transaction right now.'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  double? _parseAmount(String? raw) {
    if (raw == null) {
      return null;
    }
    final String cleaned = raw.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  double? _parseNumber(String? raw) {
    if (raw == null) {
      return null;
    }
    final String cleaned = raw.replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }

  String? _emptyToNull(String raw) {
    final String trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SplitPreview extends StatelessWidget {
  const _SplitPreview({
    required this.amountController,
    required this.bizPctController,
  });

  final TextEditingController amountController;
  final TextEditingController bizPctController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        amountController,
        bizPctController,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double amount =
            double.tryParse(amountController.text.replaceAll(',', '').trim()) ??
            0;
        final double bizPct =
            (double.tryParse(
                  bizPctController.text.replaceAll(',', '').trim(),
                ) ??
                0) /
            100;

        if (amount <= 0 || bizPct <= 0) {
          return const SizedBox.shrink();
        }

        final double clampedBizPct = bizPct.clamp(0, 1);
        final double personal = calculatePersonalAmount(amount, clampedBizPct);
        final double business = calculateBusinessAmount(amount, clampedBizPct);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            borderRadius: BorderRadius.circular(AppConstants.spacingSm),
          ),
          child: Text(
            'Personal: \$${personal.toStringAsFixed(2)} | '
            'Biz %: ${(clampedBizPct * 100).toStringAsFixed(0)}% | '
            'Business: \$${business.toStringAsFixed(2)}',
            style: AppTextStyles.body,
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(message, style: AppTextStyles.body.copyWith(color: AppColors.red)),
        const SizedBox(height: AppConstants.spacingMd),
        ElevatedButton(onPressed: onClose, child: const Text('Close')),
      ],
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.parentCategories,
    required this.subcategoriesByParent,
  });

  final List<String> parentCategories;
  final Map<String, List<String>> subcategoriesByParent;

  factory _CategoryData.fromCategories(List<Category> categories) {
    final Map<String, List<Category>> grouped = <String, List<Category>>{};

    for (final Category category in categories) {
      grouped
          .putIfAbsent(category.parentCategory, () => <Category>[])
          .add(category);
    }

    final List<String> parents = grouped.keys.toList(growable: false)
      ..sort(compareCategoryOrder);

    final Map<String, List<String>> subcategoriesByParent =
        <String, List<String>>{};
    for (final String parent in parents) {
      final List<Category> rows = List<Category>.from(grouped[parent]!)
        ..sort((Category a, Category b) {
          final int orderCmp = a.sortOrder.compareTo(b.sortOrder);
          if (orderCmp != 0) {
            return orderCmp;
          }
          return a.subcategory.compareTo(b.subcategory);
        });
      subcategoriesByParent[parent] = rows
          .map((Category c) => c.subcategory)
          .toList(growable: false);
    }

    subcategoriesByParent.putIfAbsent(
      'Transfers',
      () => <String>['Credit Card Payment', 'Account Transfer'],
    );
    if (!parents.contains('Transfers')) {
      parents.add('Transfers');
    }

    return _CategoryData(
      parentCategories: parents,
      subcategoriesByParent: subcategoriesByParent,
    );
  }
}
