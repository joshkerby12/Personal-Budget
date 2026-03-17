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

class MileageMobileScreen extends ConsumerWidget {
  const MileageMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String?> orgIdAsync = ref.watch(mileageOrgIdProvider);
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
          mileageTripsProvider(orgId),
        );

        return tripsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => const Center(
            child: ErrorView(message: 'Unable to load trips right now.'),
          ),
          data: (List<MileageTrip> trips) {
            final _TripSummary summary = _TripSummary.fromTrips(trips);

            return Padding(
              padding: const EdgeInsets.all(AppConstants.pagePaddingMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Mileage Log', style: AppTextStyles.pageTitle),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _openForm(context, orgId),
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Add Trip',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  _SummaryGrid(summary: summary),
                  const SizedBox(height: AppConstants.spacingMd),
                  Expanded(
                    child: trips.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            itemCount: trips.length,
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(
                                      height: AppConstants.spacingSm,
                                    ),
                            itemBuilder: (BuildContext context, int index) {
                              final MileageTrip trip = trips[index];
                              final double dedValue = calc.deductibleValue(
                                calc.deductibleMiles(
                                  calc.totalMiles(
                                    trip.oneWayMiles,
                                    trip.isRoundTrip,
                                  ),
                                  trip.bizPct,
                                ),
                                calc.fallbackIrsRatePerMile,
                              );
                              return Card(
                                child: ListTile(
                                  onTap: () =>
                                      _openForm(context, orgId, trip: trip),
                                  title: Text(
                                    trip.purpose,
                                    style: AppTextStyles.cardTitle,
                                  ),
                                  subtitle: Text(
                                    DateFormat('MMM d, yyyy').format(trip.date),
                                    style: AppTextStyles.body,
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        '${calc.totalMiles(trip.oneWayMiles, trip.isRoundTrip).toStringAsFixed(1)} mi',
                                        style: AppTextStyles.body,
                                      ),
                                      Text(
                                        '\$${dedValue.toStringAsFixed(2)} deductible',
                                        style: AppTextStyles.label.copyWith(
                                          color: AppColors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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

  Future<void> _openForm(
    BuildContext context,
    String orgId, {
    MileageTrip? trip,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return MileageForm(
          orgId: orgId,
          initialTrip: trip,
          onClose: () => Navigator.of(sheetContext).pop(),
        );
      },
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final _TripSummary summary;

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
              label: 'Total Trips',
              value: summary.totalTrips.toString(),
              accent: AppColors.teal,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Total Miles',
              value: summary.totalMiles.toStringAsFixed(1),
              accent: AppColors.teal,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Deductible Miles',
              value: summary.deductibleMiles.toStringAsFixed(1),
              accent: AppColors.green,
            ),
            _SummaryTile(
              width: tileWidth,
              label: 'Deductible Value',
              value: '\$${summary.deductibleValue.toStringAsFixed(2)}',
              accent: AppColors.green,
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
  });

  final double width;
  final String label;
  final String value;
  final Color accent;

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
              Text(value, style: AppTextStyles.amountLarge),
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
          Icon(Icons.route_outlined, size: 36, color: AppColors.textMuted),
          SizedBox(height: AppConstants.spacingSm),
          Text('No trips logged yet', style: AppTextStyles.cardTitle),
          SizedBox(height: AppConstants.spacingXs),
          Text('Tap + to add your first trip', style: AppTextStyles.body),
        ],
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
