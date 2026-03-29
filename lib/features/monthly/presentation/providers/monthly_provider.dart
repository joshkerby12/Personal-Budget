import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../settings/models/budget_default.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../transactions/helpers/transaction_calculations.dart';
import '../../../transactions/models/transaction.dart';

part 'monthly_provider.g.dart';

@riverpod
Future<String?> monthlyOrgId(Ref ref) async {
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
Future<MonthlyBudgetData> monthlyBudgetData(
  Ref ref,
  String orgId,
  int year,
  int month,
) async {
  final client = ref.watch(supabaseClientProvider);
  final DateTime monthStart = DateTime.utc(year, month, 1);
  final DateTime monthEnd = DateTime.utc(year, month + 1, 1);

  final String monthStartString = _formatDate(monthStart);
  final String monthEndString = _formatDate(monthEnd);

  final Future<List<dynamic>> transactionsFuture = client
      .from('transactions')
      .select()
      .eq('org_id', orgId)
      .gte('date', monthStartString)
      .lt('date', monthEndString)
      .order('date', ascending: true)
      .order('created_at', ascending: true);

  final Future<List<dynamic>> globalDefaultsFuture = client
      .from('budgets')
      .select()
      .eq('org_id', orgId)
      .isFilter('month', null)
      .order('category', ascending: true)
      .order('subcategory', ascending: true);

  final Future<List<dynamic>> monthOverridesFuture = client
      .from('budgets')
      .select()
      .eq('org_id', orgId)
      .eq('month', monthStartString)
      .order('category', ascending: true)
      .order('subcategory', ascending: true);

  final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
    transactionsFuture,
    globalDefaultsFuture,
    monthOverridesFuture,
  ]);

  final List<Transaction> transactions = (results[0] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(Transaction.fromJson)
      .toList(growable: false);

  final List<BudgetDefault> globalDefaults = (results[1] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(BudgetDefault.fromJson)
      .toList(growable: false);

  final List<BudgetDefault> monthOverrides = (results[2] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(BudgetDefault.fromJson)
      .toList(growable: false);

  final Map<String, BudgetDefault> globalByKey = <String, BudgetDefault>{
    for (final BudgetDefault row in globalDefaults)
      _budgetKey(row.category, row.subcategory): row,
  };
  final Map<String, BudgetDefault> overrideByKey = <String, BudgetDefault>{
    for (final BudgetDefault row in monthOverrides)
      _budgetKey(row.category, row.subcategory): row,
  };

  final Map<String, _ActualAccumulator> actualByKey =
      <String, _ActualAccumulator>{};
  for (final Transaction transaction in transactions) {
    final String key = _budgetKey(
      transaction.category,
      transaction.subcategory,
    );
    final _ActualAccumulator accumulator = actualByKey.putIfAbsent(
      key,
      _ActualAccumulator.new,
    );
    accumulator.add(transaction.amount, transaction.bizPct);
  }

  // Use globalDefaults (budgets WHERE month IS NULL) as the source of truth
  // for what subcategories exist. This matches exactly what the Settings page
  // manages. Deleted subcategories won't be in globalByKey so they're excluded.
  const String catchAllCategory = 'Other';
  const String catchAllSubcategory = 'Uncategorized';
  final String catchAllKey = _budgetKey(catchAllCategory, catchAllSubcategory);

  final LinkedHashSet<String> seenKeys = LinkedHashSet<String>();
  for (final BudgetDefault d in globalDefaults) {
    seenKeys.add(_budgetKey(d.category, d.subcategory));
  }
  // Always include the catch-all and Transfer subcategories
  seenKeys.add(catchAllKey);
  seenKeys.add(_budgetKey('Transfers', 'Credit Card Payment'));
  seenKeys.add(_budgetKey('Transfers', 'Account Transfer'));
  // Reroute transactions whose category/subcategory isn't in globalDefaults
  // into the catch-all bucket
  for (final Transaction t in transactions) {
    final String key = _budgetKey(t.category, t.subcategory);
    if (!seenKeys.contains(key)) {
      final _ActualAccumulator acc = actualByKey.putIfAbsent(
        catchAllKey,
        _ActualAccumulator.new,
      );
      acc.add(t.amount, t.bizPct);
    }
  }
  // Include all month override keys so month-scoped subcategories appear in
  // the selected month even when no global default exists.
  seenKeys.addAll(overrideByKey.keys);
  // Include actual keys only for known subcategories
  seenKeys.addAll(actualByKey.keys.where(seenKeys.contains));

  final List<String> allKeys = seenKeys.toList(growable: false);
  final Map<String, int> insertionIndex = <String, int>{
    for (int i = 0; i < allKeys.length; i++) allKeys[i]: i,
  };
  final List<String> orderedKeys = List<String>.from(allKeys)
    ..sort((String a, String b) {
      final String catA = _parseBudgetKey(a).$1;
      final String catB = _parseBudgetKey(b).$1;
      final int parentCmp = compareCategoryOrder(catA, catB);
      if (parentCmp != 0) return parentCmp;
      return insertionIndex[a]!.compareTo(insertionIndex[b]!);
    });

  final List<MonthlyRow> rows = <MonthlyRow>[];
  final Map<String, ({double budget, double actual, double business})>
  subtotals = <String, ({double budget, double actual, double business})>{};

  for (final String key in orderedKeys) {
    final (String category, String subcategory) = _parseBudgetKey(key);
    final BudgetDefault? global = globalByKey[key];
    final BudgetDefault? override = overrideByKey[key];
    final _ActualAccumulator? actualAccumulator = actualByKey[key];

    final double budget = override?.monthlyAmount ?? global?.monthlyAmount ?? 0;
    final double globalBudget = global?.monthlyAmount ?? 0;
    final double actual = actualAccumulator?.actual ?? 0;
    final double bizPct = actualAccumulator?.weightedBizPct ?? 0;
    final double personal = calculatePersonalAmount(actual, bizPct);
    final double business = calculateBusinessAmount(actual, bizPct);
    final double remaining = budget - actual;
    final bool hasCustomBudget = override != null;
    final double defaultBizPct =
        override?.defaultBizPct ?? global?.defaultBizPct ?? 0;
    final String? monthOverrideId = (override != null && override.id.isNotEmpty)
        ? override.id
        : null;
    final bool isMonthScoped = global == null && override != null;

    rows.add(
      MonthlyRow(
        category: category,
        subcategory: subcategory,
        budget: budget,
        actual: actual,
        remaining: remaining,
        personal: personal,
        business: business,
        bizPct: bizPct,
        hasCustomBudget: hasCustomBudget,
        globalBudget: globalBudget,
        defaultBizPct: defaultBizPct,
        monthOverrideId: monthOverrideId,
        isMonthScoped: isMonthScoped,
      ),
    );

    final ({double budget, double actual, double business}) existing =
        subtotals[category] ?? (budget: 0, actual: 0, business: 0);

    subtotals[category] = (
      budget: existing.budget + budget,
      actual: existing.actual + actual,
      business: existing.business + business,
    );
  }

  // Calculate month income from transactions to detect over-budget
  double monthIncome = 0;
  double totalBudgeted = 0;
  for (final Transaction t in transactions) {
    if (isIncome(t.category)) monthIncome += t.amount;
  }
  for (final MonthlyRow row in rows) {
    if (!isTransfer(row.category)) totalBudgeted += row.budget;
  }

  return MonthlyBudgetData(
    year: year,
    month: month,
    hasCustomBudgets: monthOverrides.isNotEmpty,
    rows: rows,
    transactions: transactions,
    categorySubtotals: subtotals,
    monthIncome: monthIncome,
    totalBudgeted: totalBudgeted,
  );
}

@riverpod
class MonthlyController extends _$MonthlyController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> saveMonthBudgets(
    String orgId,
    int year,
    int month,
    List<BudgetDefault> budgets,
  ) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      final DateTime monthStart = DateTime.utc(year, month, 1);
      final List<BudgetDefault> normalized = budgets
          .map(
            (BudgetDefault row) => row.copyWith(
              orgId: orgId,
              month: monthStart,
              defaultBizPct: row.defaultBizPct.clamp(0, 1),
            ),
          )
          .toList(growable: false);

      final settingsService = ref.read(settingsServiceProvider);
      await settingsService.clearMonthOverrides(orgId, monthStart);
      if (normalized.isNotEmpty) {
        await settingsService.saveBudgetDefaults(normalized);
      }

      ref
        ..invalidate(monthlyBudgetDataProvider(orgId, year, month))
        ..invalidate(budgetDefaultsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> clearMonthOverrides(String orgId, int year, int month) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      final DateTime monthStart = DateTime.utc(year, month, 1);
      await ref
          .read(settingsServiceProvider)
          .clearMonthOverrides(orgId, monthStart);

      ref
        ..invalidate(monthlyBudgetDataProvider(orgId, year, month))
        ..invalidate(budgetDefaultsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

class MonthlyBudgetData {
  const MonthlyBudgetData({
    required this.year,
    required this.month,
    required this.hasCustomBudgets,
    required this.rows,
    required this.transactions,
    required this.categorySubtotals,
    required this.monthIncome,
    required this.totalBudgeted,
  });

  final int year;
  final int month;
  final bool hasCustomBudgets;
  final List<MonthlyRow> rows;
  final List<Transaction> transactions;
  final Map<String, ({double budget, double actual, double business})>
  categorySubtotals;

  /// Sum of income transactions for this month (0 if none yet)
  final double monthIncome;

  /// Sum of all budgeted expense amounts for this month
  final double totalBudgeted;

  /// True when total budgeted expenses exceed known income for the month
  bool get isOverBudget => monthIncome > 0 && totalBudgeted > monthIncome;
}

class MonthlyRow {
  const MonthlyRow({
    required this.category,
    required this.subcategory,
    required this.budget,
    required this.actual,
    required this.remaining,
    required this.personal,
    required this.business,
    required this.bizPct,
    required this.hasCustomBudget,
    required this.globalBudget,
    required this.defaultBizPct,
    required this.monthOverrideId,
    required this.isMonthScoped,
  });

  final String category;
  final String subcategory;
  final double budget;
  final double actual;
  final double remaining;
  final double personal;
  final double business;
  final double bizPct;
  final bool hasCustomBudget;
  final double globalBudget;
  final double defaultBizPct;
  final String? monthOverrideId;
  final bool isMonthScoped;

  String get key => _budgetKey(category, subcategory);
}

class _ActualAccumulator {
  double actual = 0;
  double weightedBizNumerator = 0;

  void add(double amount, double bizPct) {
    actual += amount;
    weightedBizNumerator += amount * bizPct;
  }

  double get weightedBizPct {
    if (actual <= 0) {
      return 0;
    }
    return (weightedBizNumerator / actual).clamp(0, 1);
  }
}

String _budgetKey(String category, String subcategory) {
  return '$category\u0000$subcategory';
}

(String, String) _parseBudgetKey(String key) {
  final int index = key.indexOf('\u0000');
  if (index == -1) {
    return (key, '');
  }

  return (key.substring(0, index), key.substring(index + 1));
}

String _formatDate(DateTime date) {
  final String year = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
