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

class BusinessMobileScreen extends ConsumerWidget {
  const BusinessMobileScreen({super.key});

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
            final bool showEmptyState =
                summary.byCategory.isEmpty &&
                summary.totalMiles == 0 &&
                summary.mileageDeductibleMiles == 0 &&
                summary.mileageDeductionValue == 0;

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.pagePaddingMobile),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Business Summary', style: AppTextStyles.pageTitle),
                    const SizedBox(height: AppConstants.spacingSm),
                    BusinessFilterBar(
                      selectedYear: selectedYear,
                      selectedMonth: selectedMonth,
                      onYearChanged: (int? value) {
                        ref.read(_yearFilterProvider.notifier).state = value;
                        if (value == null) {
                          ref.read(_monthFilterProvider.notifier).state = null;
                        }
                      },
                      onMonthChanged: (int? value) {
                        ref.read(_monthFilterProvider.notifier).state = value;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    if (showEmptyState)
                      const Expanded(child: _EmptyState())
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _SummaryGrid(
                                summary: summary,
                                currencyFormat: _currencyFormat,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                              _MileageCard(
                                summary: summary,
                                currencyFormat: _currencyFormat,
                                irsRateFormat: _irsRateFormat,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                              _ByCategoryCard(
                                summary: summary,
                                currencyFormat: _currencyFormat,
                              ),
                            ],
                          ),
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

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary, required this.currencyFormat});

  final BusinessSummaryData summary;
  final NumberFormat currencyFormat;

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
              label: 'Business Expenses',
              value: currencyFormat.format(summary.totalBusinessExpenses),
              accent: AppColors.teal,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Mileage Deduction',
              value: currencyFormat.format(summary.mileageDeductionValue),
              accent: AppColors.green,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Combined Deductions',
              value: currencyFormat.format(summary.combinedDeductions),
              accent: AppColors.navy,
              emphasizeValue: true,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Business % of Total',
              value: '${summary.businessExpensePct.toStringAsFixed(1)}%',
              accent: AppColors.amber,
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
    this.emphasizeValue = false,
  });

  final double width;
  final String label;
  final String value;
  final Color accent;
  final bool emphasizeValue;

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
              Text(label, style: AppTextStyles.label),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                value,
                style: AppTextStyles.amountLarge.copyWith(
                  fontSize: 20,
                  fontWeight: emphasizeValue
                      ? FontWeight.w800
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MileageCard extends StatelessWidget {
  const _MileageCard({
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Mileage Deduction', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            _MetricRow(
              label: 'Total Trips',
              value: summary.totalTrips.toString(),
            ),
            _MetricRow(
              label: 'Total Miles',
              value: summary.totalMiles.toStringAsFixed(1),
            ),
            _MetricRow(
              label: 'Deductible Miles',
              value: summary.mileageDeductibleMiles.toStringAsFixed(1),
            ),
            _MetricRow(
              label: 'IRS Rate',
              value: '${irsRateFormat.format(summary.irsRate)}/mi',
            ),
            _MetricRow(
              label: 'Total Deduction',
              value: currencyFormat.format(summary.mileageDeductionValue),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ByCategoryCard extends StatelessWidget {
  const _ByCategoryCard({required this.summary, required this.currencyFormat});

  final BusinessSummaryData summary;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('By Category', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppConstants.spacingSm),
            if (summary.byCategory.isEmpty)
              const Text(
                'No business expenses for this period',
                style: AppTextStyles.body,
              )
            else
              ...summary.byCategory.map(
                (BusinessCategoryRow row) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppConstants.spacingSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              row.category,
                              style: AppTextStyles.cardTitle,
                            ),
                          ),
                          Text(
                            currencyFormat.format(row.businessAmount),
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${row.pctOfTotalBusiness.toStringAsFixed(1)}% of business',
                        style: AppTextStyles.label,
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.business_center_outlined,
            size: 40,
            color: AppColors.textMuted,
          ),
          SizedBox(height: AppConstants.spacingSm),
          Text(
            'No business activity for this period',
            style: AppTextStyles.cardTitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
