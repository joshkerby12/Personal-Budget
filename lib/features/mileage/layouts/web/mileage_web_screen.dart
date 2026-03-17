import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../helpers/mileage_calculations.dart' as calc;
import '../../models/mileage_trip.dart';
import '../../presentation/providers/mileage_provider.dart';
import '../../presentation/widgets/mileage_form.dart';

final AutoDisposeStateProvider<int?> _yearFilterProvider =
    StateProvider.autoDispose<int?>((Ref ref) => DateTime.now().year);
final AutoDisposeStateProvider<int?> _monthFilterProvider =
    StateProvider.autoDispose<int?>((Ref ref) => null);

class MileageWebScreen extends ConsumerWidget {
  const MileageWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(mileageOrgIdProvider);
    final int? selectedYear = ref.watch(_yearFilterProvider);
    final int? selectedMonth = ref.watch(_monthFilterProvider);

    return orgIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => const Center(
        child: ErrorView(message: 'Unable to load mileage data.'),
      ),
      data: (String? orgId) {
        if (orgId == null) {
          return const Center(
            child: ErrorView(message: 'No organization found for this user.'),
          );
        }

        final AsyncValue<List<MileageTrip>> tripsAsync = ref.watch(
          mileageTripsProvider(orgId, year: selectedYear, month: selectedMonth),
        );

        return tripsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load trips right now.'),
          ),
          data: (List<MileageTrip> trips) {
            final _TripSummary summary = _TripSummary.fromTrips(trips);
            final List<int> yearOptions = List<int>.generate(
              6,
              (int index) => DateTime.now().year - index,
            );

            return Padding(
              padding: const EdgeInsets.all(AppConstants.pagePaddingDesktop),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Mileage Log', style: AppTextStyles.pageTitle),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  _SummaryRow(summary: summary),
                  const SizedBox(height: AppConstants.spacingMd),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 130,
                        child: DropdownButtonFormField<int?>(
                          key: ValueKey<int?>(selectedYear),
                          initialValue: selectedYear,
                          decoration: const InputDecoration(labelText: 'Year'),
                          items: <DropdownMenuItem<int?>>[
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Years'),
                            ),
                            ...yearOptions.map(
                              (int year) => DropdownMenuItem<int?>(
                                value: year,
                                child: Text(year.toString()),
                              ),
                            ),
                          ],
                          onChanged: (int? value) =>
                              ref.read(_yearFilterProvider.notifier).state =
                                  value,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<int?>(
                          key: ValueKey<int?>(selectedMonth),
                          initialValue: selectedMonth,
                          decoration: const InputDecoration(labelText: 'Month'),
                          items: const <DropdownMenuItem<int?>>[
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Months'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 1,
                              child: Text('Jan'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 2,
                              child: Text('Feb'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 3,
                              child: Text('Mar'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 4,
                              child: Text('Apr'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 5,
                              child: Text('May'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 6,
                              child: Text('Jun'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 7,
                              child: Text('Jul'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 8,
                              child: Text('Aug'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 9,
                              child: Text('Sep'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 10,
                              child: Text('Oct'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 11,
                              child: Text('Nov'),
                            ),
                            DropdownMenuItem<int?>(
                              value: 12,
                              child: Text('Dec'),
                            ),
                          ],
                          onChanged: (int? value) =>
                              ref.read(_monthFilterProvider.notifier).state =
                                  value,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _openDialog(context, orgId),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Trip'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Expanded(
                    child: Card(
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
                                _HeaderCell('Purpose', flex: 3),
                                _HeaderCell('From', flex: 2),
                                _HeaderCell('To', flex: 2),
                                _HeaderCell('Miles', flex: 1),
                                _HeaderCell('RT', flex: 1),
                                _HeaderCell('Biz%', flex: 1),
                                _HeaderCell('Ded. Miles', flex: 2),
                                _HeaderCell('Ded. Value', flex: 2),
                                _HeaderCell('Actions', flex: 2),
                              ],
                            ),
                          ),
                          Expanded(
                            child: trips.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No trips logged yet',
                                      style: AppTextStyles.body,
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: trips.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final MileageTrip trip = trips[index];
                                      final bool isEven = index.isEven;
                                      final double total = calc.totalMiles(
                                        trip.oneWayMiles,
                                        trip.isRoundTrip,
                                      );
                                      final double dedMiles = calc
                                          .deductibleMiles(total, trip.bizPct);
                                      final double dedValue = calc
                                          .deductibleValue(
                                            dedMiles,
                                            calc.fallbackIrsRatePerMile,
                                          );
                                      return Container(
                                        color: isEven
                                            ? AppColors.white
                                            : AppColors.lightGray,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppConstants.spacingMd,
                                          vertical: AppConstants.spacingSm,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            _BodyCell(
                                              DateFormat(
                                                'MMM d, yyyy',
                                              ).format(trip.date),
                                              flex: 2,
                                            ),
                                            _BodyCell(trip.purpose, flex: 3),
                                            _BodyCell(
                                              trip.fromAddress,
                                              flex: 2,
                                            ),
                                            _BodyCell(trip.toAddress, flex: 2),
                                            _BodyCell(
                                              total.toStringAsFixed(1),
                                              flex: 1,
                                            ),
                                            _BodyCell(
                                              trip.isRoundTrip ? 'Yes' : 'No',
                                              flex: 1,
                                            ),
                                            _BodyCell(
                                              '${(trip.bizPct * 100).toStringAsFixed(0)}%',
                                              flex: 1,
                                            ),
                                            _BodyCell(
                                              dedMiles.toStringAsFixed(1),
                                              flex: 2,
                                            ),
                                            _BodyCell(
                                              '\$${dedValue.toStringAsFixed(2)}',
                                              flex: 2,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: <Widget>[
                                                  IconButton(
                                                    onPressed: () =>
                                                        _openDialog(
                                                          context,
                                                          orgId,
                                                          trip: trip,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _openDialog(
                                                          context,
                                                          orgId,
                                                          trip: trip,
                                                        ),
                                                    color: AppColors.red,
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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

  Future<void> _openDialog(
    BuildContext context,
    String orgId, {
    MileageTrip? trip,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: MileageForm(
              orgId: orgId,
              initialTrip: trip,
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final _TripSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _SummaryTile(
          label: 'Total Trips',
          value: summary.totalTrips.toString(),
          accent: AppColors.teal,
        ),
        const SizedBox(width: AppConstants.spacingSm),
        _SummaryTile(
          label: 'Total Miles',
          value: summary.totalMiles.toStringAsFixed(1),
          accent: AppColors.teal,
        ),
        const SizedBox(width: AppConstants.spacingSm),
        _SummaryTile(
          label: 'Deductible Miles',
          value: summary.deductibleMiles.toStringAsFixed(1),
          accent: AppColors.green,
        ),
        const SizedBox(width: AppConstants.spacingSm),
        _SummaryTile(
          label: 'Deductible Value',
          value: '\$${summary.deductibleValue.toStringAsFixed(2)}',
          accent: AppColors.green,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
              Text(value, style: AppTextStyles.amountLarge),
            ],
          ),
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
      child: Text(label, style: AppTextStyles.button.copyWith(fontSize: 13)),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.value, {required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body,
      ),
    );
  }
}

class _TripSummary {
  const _TripSummary({
    required this.totalTrips,
    required this.totalMiles,
    required this.deductibleMiles,
    required this.deductibleValue,
  });

  final int totalTrips;
  final double totalMiles;
  final double deductibleMiles;
  final double deductibleValue;

  factory _TripSummary.fromTrips(List<MileageTrip> trips) {
    double allMiles = 0;
    double allDeductibleMiles = 0;
    double allDeductibleValue = 0;
    for (final MileageTrip trip in trips) {
      final double total = calc.totalMiles(trip.oneWayMiles, trip.isRoundTrip);
      final double dedMiles = calc.deductibleMiles(total, trip.bizPct);
      final double dedValue = calc.deductibleValue(
        dedMiles,
        calc.fallbackIrsRatePerMile,
      );
      allMiles += total;
      allDeductibleMiles += dedMiles;
      allDeductibleValue += dedValue;
    }

    return _TripSummary(
      totalTrips: trips.length,
      totalMiles: allMiles,
      deductibleMiles: allDeductibleMiles,
      deductibleValue: allDeductibleValue,
    );
  }
}
