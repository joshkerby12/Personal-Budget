import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../presentation/providers/business_provider.dart';
import '../../presentation/widgets/business_filter_bar.dart';

final AutoDisposeStateProvider<int?> _yearFilterProvider =
    StateProvider.autoDispose<int?>((Ref ref) => DateTime.now().year);
final AutoDisposeStateProvider<int?> _monthFilterProvider =
    StateProvider.autoDispose<int?>((Ref ref) => null);

class BusinessWebScreen extends ConsumerWidget {
  const BusinessWebScreen({super.key});

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
  );
  static final NumberFormat _irsRateFormat = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 3,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? selectedYear = ref.watch(_yearFilterProvider);
    final int? selectedMonth = ref.watch(_monthFilterProvider);
    final AsyncValue<String?> orgIdAsync = ref.watch(businessOrgIdProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load business summary.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<BusinessSummaryData> summaryAsync = ref.watch(
          businessSummaryProvider(
            orgId,
            year: selectedYear,
            month: selectedMonth,
          ),
        );

        return summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(
              message: 'Unable to load business data right now.',
            ),
          ),
          data: (BusinessSummaryData summary) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.pagePaddingDesktop),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Business Summary', style: AppTextStyles.pageTitle),
                      const SizedBox(height: AppConstants.spacingMd),
                      BusinessFilterBar(
                        selectedYear: selectedYear,
                        selectedMonth: selectedMonth,
                        onYearChanged: (int? value) {
                          ref.read(_yearFilterProvider.notifier).state = value;
                          if (value == null) {
                            ref.read(_monthFilterProvider.notifier).state =
                                null;
                          }
                        },
                        onMonthChanged: (int? value) {
                          ref.read(_monthFilterProvider.notifier).state = value;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      _SummaryCards(
                        summary: summary,
                        currencyFormat: _currencyFormat,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      _MileageDetailBlock(
                        summary: summary,
                        currencyFormat: _currencyFormat,
                        irsRateFormat: _irsRateFormat,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      Expanded(
                        child: _CategoryTable(
                          summary: summary,
                          currencyFormat: _currencyFormat,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary, required this.currencyFormat});

  final BusinessSummaryData summary;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SummaryCard(
            label: 'Business Expenses',
            value: currencyFormat.format(summary.totalBusinessExpenses),
            accent: AppColors.teal,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _SummaryCard(
            label: 'Mileage Deduction',
            value: currencyFormat.format(summary.mileageDeductionValue),
            accent: AppColors.green,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _SummaryCard(
            label: 'Combined Deductions',
            value: currencyFormat.format(summary.combinedDeductions),
            accent: AppColors.navy,
            emphasizeValue: true,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _SummaryCard(
            label: 'Business % of Total',
            value: '${summary.businessExpensePct.toStringAsFixed(1)}%',
            accent: AppColors.amber,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accent,
    this.emphasizeValue = false,
  });

  final String label;
  final String value;
  final Color accent;
  final bool emphasizeValue;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              value,
              style: AppTextStyles.amountLarge.copyWith(
                fontSize: 20,
                fontWeight: emphasizeValue ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MileageDetailBlock extends StatelessWidget {
  const _MileageDetailBlock({
    required this.summary,
    required this.currencyFormat,
    required this.irsRateFormat,
  });

  final BusinessSummaryData summary;
  final NumberFormat currencyFormat;
  final NumberFormat irsRateFormat;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.tealLight,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              _MileageItem(
                label: 'Total Trips',
                value: summary.totalTrips.toString(),
              ),
              const SizedBox(width: AppConstants.spacingLg),
              _MileageItem(
                label: 'Total Miles',
                value: summary.totalMiles.toStringAsFixed(1),
              ),
              const SizedBox(width: AppConstants.spacingLg),
              _MileageItem(
                label: 'Deductible Miles',
                value: summary.mileageDeductibleMiles.toStringAsFixed(1),
              ),
              const SizedBox(width: AppConstants.spacingLg),
              _MileageItem(
                label: 'IRS Rate',
                value: '${irsRateFormat.format(summary.irsRate)}/mi',
              ),
              const SizedBox(width: AppConstants.spacingLg),
              _MileageItem(
                label: 'Total Deduction',
                value: currencyFormat.format(summary.mileageDeductionValue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MileageItem extends StatelessWidget {
  const _MileageItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: AppConstants.spacingXs),
        Text(
          value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CategoryTable extends StatelessWidget {
  const _CategoryTable({required this.summary, required this.currencyFormat});

  final BusinessSummaryData summary;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(
                  flex: 3,
                  child: Text('Category', style: AppTextStyles.button),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Business (\$)',
                    style: AppTextStyles.button,
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '% of Business Total',
                    style: AppTextStyles.button,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          if (summary.byCategory.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No business expenses for this period',
                  style: AppTextStyles.body,
                ),
              ),
            )
          else ...<Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: summary.byCategory.length,
                itemBuilder: (BuildContext context, int index) {
                  final BusinessCategoryRow row = summary.byCategory[index];
                  final Color rowColor = index.isEven
                      ? AppColors.white
                      : AppColors.lightGray;
                  return Container(
                    color: rowColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingSm,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Text(row.category, style: AppTextStyles.body),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormat.format(row.businessAmount),
                            style: AppTextStyles.body,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${row.pctOfTotalBusiness.toStringAsFixed(1)}%',
                            style: AppTextStyles.body,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              color: AppColors.midGray,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    flex: 3,
                    child: Text('Total', style: AppTextStyles.cardTitle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currencyFormat.format(summary.totalBusinessExpenses),
                      style: AppTextStyles.cardTitle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      summary.totalBusinessExpenses == 0 ? '0.0%' : '100.0%',
                      style: AppTextStyles.cardTitle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
