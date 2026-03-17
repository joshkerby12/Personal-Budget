import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../mileage/helpers/mileage_calculations.dart' as mileage_calc;
import '../../../mileage/models/mileage_trip.dart';
import '../../../mileage/presentation/providers/mileage_provider.dart';
import '../../../settings/models/app_settings.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart' as tx_calc;
import '../../../transactions/models/transaction.dart';
import '../../../transactions/models/transaction_filter.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

part 'business_provider.g.dart';

class BusinessSummaryData {
  const BusinessSummaryData({
    required this.totalExpenses,
    required this.totalBusinessExpenses,
    required this.businessExpensePct,
    required this.totalTrips,
    required this.totalMiles,
    required this.mileageDeductibleMiles,
    required this.mileageDeductionValue,
    required this.irsRate,
    required this.combinedDeductions,
    required this.byCategory,
  });

  final double totalExpenses;
  final double totalBusinessExpenses;
  final double businessExpensePct;
  final int totalTrips;
  final double totalMiles;
  final double mileageDeductibleMiles;
  final double mileageDeductionValue;
  final double irsRate;
  final double combinedDeductions;
  final List<BusinessCategoryRow> byCategory;
}

class BusinessCategoryRow {
  const BusinessCategoryRow({
    required this.category,
    required this.totalExpenses,
    required this.businessAmount,
    required this.pctOfTotalBusiness,
  });

  final String category;
  final double totalExpenses;
  final double businessAmount;
  final double pctOfTotalBusiness;
}

class _CategoryAccumulator {
  const _CategoryAccumulator({
    required this.totalExpenses,
    required this.businessAmount,
  });

  final double totalExpenses;
  final double businessAmount;
}

@riverpod
Future<String?> businessOrgId(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null) {
    return null;
  }

  final Map<String, dynamic>? member = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  return member?['org_id'] as String?;
}

@riverpod
Future<BusinessSummaryData> businessSummary(
  Ref ref,
  String orgId, {
  int? year,
  int? month,
}) async {
  final Future<List<Transaction>> transactionsFuture = ref.watch(
    transactionsProvider(
      orgId,
      filter: TransactionFilter(year: year, month: month),
    ).future,
  );
  final Future<List<MileageTrip>> tripsFuture = ref.watch(
    mileageTripsProvider(orgId).future,
  );
  final Future<AppSettings?> appSettingsFuture = ref.watch(
    appSettingsProvider(orgId).future,
  );

  final List<Transaction> transactions = await transactionsFuture;
  final List<MileageTrip> allTrips = await tripsFuture;
  final AppSettings? appSettings = await appSettingsFuture;

  final List<Transaction> expenseTransactions = transactions
      .where(
        (Transaction transaction) => !tx_calc.isIncome(transaction.category),
      )
      .toList(growable: false);

  double totalExpenses = 0;
  double totalBusinessExpenses = 0;
  final Map<String, _CategoryAccumulator> byCategoryAccumulator =
      <String, _CategoryAccumulator>{};

  for (final Transaction transaction in expenseTransactions) {
    final double businessAmount = tx_calc.calculateBusinessAmount(
      transaction.amount,
      transaction.bizPct,
    );
    totalExpenses += transaction.amount;
    totalBusinessExpenses += businessAmount;

    final _CategoryAccumulator current =
        byCategoryAccumulator[transaction.category] ??
        const _CategoryAccumulator(totalExpenses: 0, businessAmount: 0);

    byCategoryAccumulator[transaction.category] = _CategoryAccumulator(
      totalExpenses: current.totalExpenses + transaction.amount,
      businessAmount: current.businessAmount + businessAmount,
    );
  }

  final List<MileageTrip> filteredTrips = allTrips
      .where((MileageTrip trip) {
        final bool matchesYear = year == null || trip.date.year == year;
        final bool matchesMonth = year == null || month == null
            ? true
            : trip.date.month == month;
        return matchesYear && matchesMonth;
      })
      .toList(growable: false);

  final double irsRate =
      appSettings?.irsRatePerMile ?? mileage_calc.fallbackIrsRatePerMile;
  double totalMiles = 0;
  double mileageDeductibleMiles = 0;
  double mileageDeductionValue = 0;

  for (final MileageTrip trip in filteredTrips) {
    final double tripMiles = mileage_calc.totalMiles(
      trip.oneWayMiles,
      trip.isRoundTrip,
    );
    final double tripDeductibleMiles = mileage_calc.deductibleMiles(
      tripMiles,
      trip.bizPct,
    );
    final double tripDeductionValue = mileage_calc.deductibleValue(
      tripDeductibleMiles,
      irsRate,
    );

    totalMiles += tripMiles;
    mileageDeductibleMiles += tripDeductibleMiles;
    mileageDeductionValue += tripDeductionValue;
  }

  final List<BusinessCategoryRow> byCategory =
      byCategoryAccumulator.entries
          .where(
            (MapEntry<String, _CategoryAccumulator> entry) =>
                entry.value.businessAmount > 0,
          )
          .map(
            (MapEntry<String, _CategoryAccumulator> entry) =>
                BusinessCategoryRow(
                  category: entry.key,
                  totalExpenses: entry.value.totalExpenses,
                  businessAmount: entry.value.businessAmount,
                  pctOfTotalBusiness: totalBusinessExpenses == 0
                      ? 0
                      : (entry.value.businessAmount / totalBusinessExpenses) *
                            100,
                ),
          )
          .toList(growable: false)
        ..sort(
          (BusinessCategoryRow a, BusinessCategoryRow b) =>
              b.businessAmount.compareTo(a.businessAmount),
        );

  final double businessExpensePct = totalExpenses == 0
      ? 0
      : (totalBusinessExpenses / totalExpenses) * 100;

  return BusinessSummaryData(
    totalExpenses: totalExpenses,
    totalBusinessExpenses: totalBusinessExpenses,
    businessExpensePct: businessExpensePct,
    totalTrips: filteredTrips.length,
    totalMiles: totalMiles,
    mileageDeductibleMiles: mileageDeductibleMiles,
    mileageDeductionValue: mileageDeductionValue,
    irsRate: irsRate,
    combinedDeductions: totalBusinessExpenses + mileageDeductionValue,
    byCategory: byCategory,
  );
}
