import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_settings.dart';
import '../models/budget_default.dart';

class SettingsService {
  const SettingsService(this._client);

  final SupabaseClient _client;

  Future<AppSettings?> fetchAppSettings(String orgId) async {
    final Map<String, dynamic>? row = await _client
        .from('app_settings')
        .select()
        .eq('org_id', orgId)
        .maybeSingle();

    if (row == null) {
      return null;
    }
    return AppSettings.fromJson(row);
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'org_id': settings.orgId,
      'irs_rate_per_mile': settings.irsRatePerMile,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (settings.id.isNotEmpty) {
      payload['id'] = settings.id;
    }

    await _client.from('app_settings').upsert(payload, onConflict: 'org_id');
  }

  Future<List<BudgetDefault>> fetchBudgetDefaults(
    String orgId, {
    DateTime? month,
  }) async {
    final PostgrestFilterBuilder<List<dynamic>> base = _client
        .from('budgets')
        .select()
        .eq('org_id', orgId);

    final PostgrestFilterBuilder<List<dynamic>> query = month == null
        ? base.isFilter('month', null)
        : base.eq('month', _formatDate(_firstDayOfMonth(month)));

    final List<dynamic> rows = await query
        .order('category', ascending: true)
        .order('sort_order', ascending: true)
        .order('subcategory', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(BudgetDefault.fromJson)
        .toList(growable: false);
  }

  Future<void> saveBudgetDefaults(
    List<BudgetDefault> defaults, {
    List<String> deleteIds = const <String>[],
  }) async {
    if (defaults.isEmpty && deleteIds.isEmpty) {
      return;
    }

    if (defaults.isNotEmpty) {
      final String orgId = defaults.first.orgId;
      if (defaults.any((BudgetDefault row) => row.orgId != orgId)) {
        throw ArgumentError('All budget defaults must belong to the same org.');
      }

      final List<BudgetDefault> existing =
          defaults.where((BudgetDefault r) => r.id.isNotEmpty).toList();
      final List<BudgetDefault> newRows =
          defaults.where((BudgetDefault r) => r.id.isEmpty).toList();

      // Update existing rows by their primary key.
      if (existing.isNotEmpty) {
        await _client.from('budgets').upsert(
          existing.map(_toBudgetWriteMap).toList(growable: false),
          onConflict: 'id',
        );
      }

      // Insert genuinely new rows one by one to get back their IDs.
      if (newRows.isNotEmpty) {
        await _client.from('budgets').insert(
          newRows.map(_toBudgetWriteMap).toList(growable: false),
        );
      }
    }

    // Delete only the rows the user explicitly removed.
    if (deleteIds.isNotEmpty) {
      await _client
          .from('budgets')
          .delete()
          .inFilter('id', deleteIds);
    }
  }

  Future<void> deleteBudgetDefault(String id) async {
    await _client.from('budgets').delete().eq('id', id);
  }

  Future<void> clearMonthOverrides(String orgId, DateTime month) async {
    await _client
        .from('budgets')
        .delete()
        .eq('org_id', orgId)
        .eq('month', _formatDate(_firstDayOfMonth(month)));
  }

  Future<void> resetGlobalDefaults(String orgId) async {
    await _client
        .from('budgets')
        .delete()
        .eq('org_id', orgId)
        .isFilter('month', null);

    final Map<String, int> categoryIndex = <String, int>{};
    final List<Map<String, dynamic>> payload = _defaultBudgetSeed
        .map(
          (_BudgetSeed item) {
            final int position = (categoryIndex[item.category] ?? 0) + 1;
            categoryIndex[item.category] = position;
            return <String, dynamic>{
              'org_id': orgId,
              'category': item.category,
              'subcategory': item.subcategory,
              'monthly_amount': item.monthlyAmount,
              'default_biz_pct': item.defaultBizPct,
              'sort_order': position * 10,
              'month': null,
            };
          },
        )
        .toList(growable: false);

    await _client.from('budgets').insert(payload);
  }

  Future<List<BudgetDefault>> ensureGlobalDefaults(String orgId) async {
    return fetchBudgetDefaults(orgId);
  }

  Future<Map<String, dynamic>> exportSettingsData(String orgId) async {
    final AppSettings? settings = await fetchAppSettings(orgId);
    final List<dynamic> budgets = await _client
        .from('budgets')
        .select()
        .eq('org_id', orgId)
        .order('category', ascending: true)
        .order('subcategory', ascending: true)
        .order('month', ascending: true);

    return <String, dynamic>{
      'version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'app_settings': settings?.toJson(),
      'budgets': budgets,
    };
  }

  Future<void> importSettingsData(
    String orgId,
    Map<String, dynamic> payload,
  ) async {
    final dynamic appSettingsPayload = payload['app_settings'];
    if (appSettingsPayload is Map<String, dynamic>) {
      final AppSettings imported = AppSettings(
        id: appSettingsPayload['id']?.toString() ?? '',
        orgId: orgId,
        irsRatePerMile: _toDouble(appSettingsPayload['irs_rate_per_mile']),
      );
      await saveAppSettings(imported);
    }

    final dynamic budgetsPayload = payload['budgets'];
    if (budgetsPayload is! List) {
      return;
    }

    final List<BudgetDefault> importedBudgets = <BudgetDefault>[];
    for (final dynamic item in budgetsPayload) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      final String category = item['category']?.toString().trim() ?? '';
      final String subcategory = item['subcategory']?.toString().trim() ?? '';
      if (category.isEmpty || subcategory.isEmpty) {
        continue;
      }

      importedBudgets.add(
        BudgetDefault(
          id: item['id']?.toString() ?? '',
          orgId: orgId,
          category: category,
          subcategory: subcategory,
          monthlyAmount: _toDouble(item['monthly_amount']),
          defaultBizPct: _toDouble(item['default_biz_pct']).clamp(0, 1),
          month: _parseDate(item['month']),
        ),
      );
    }

    await _client.from('budgets').delete().eq('org_id', orgId);
    if (importedBudgets.isNotEmpty) {
      await saveBudgetDefaults(importedBudgets);
    }
  }

  Map<String, dynamic> _toBudgetWriteMap(BudgetDefault row) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'org_id': row.orgId,
      'category': row.category,
      'subcategory': row.subcategory,
      'monthly_amount': row.monthlyAmount,
      'default_biz_pct': row.defaultBizPct.clamp(0, 1),
      'sort_order': row.sortOrder,
      'month': row.month == null
          ? null
          : _formatDate(_firstDayOfMonth(row.month!)),
    };

    if (row.id.isNotEmpty) {
      payload['id'] = row.id;
    }

    return payload;
  }

  DateTime _firstDayOfMonth(DateTime input) {
    return DateTime(input.year, input.month);
  }

  String _formatDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _BudgetSeed {
  const _BudgetSeed({required this.category, required this.subcategory})
    : monthlyAmount = 0,
      defaultBizPct = category == 'Business' ? 1 : 0;

  final String category;
  final String subcategory;
  final double monthlyAmount;
  final double defaultBizPct;
}

const List<_BudgetSeed> _defaultBudgetSeed = <_BudgetSeed>[
  _BudgetSeed(category: 'Housing', subcategory: 'Mortgage/Rent'),
  _BudgetSeed(category: 'Housing', subcategory: 'Property Tax'),
  _BudgetSeed(category: 'Housing', subcategory: 'HOA Fees'),
  _BudgetSeed(category: 'Housing', subcategory: 'Home Insurance'),
  _BudgetSeed(category: 'Housing', subcategory: 'Home Maintenance'),
  _BudgetSeed(category: 'Housing', subcategory: 'Utilities - Electric'),
  _BudgetSeed(category: 'Housing', subcategory: 'Utilities - Gas'),
  _BudgetSeed(category: 'Housing', subcategory: 'Utilities - Water'),
  _BudgetSeed(category: 'Housing', subcategory: 'Internet'),
  _BudgetSeed(category: 'Housing', subcategory: 'Phone'),
  _BudgetSeed(category: 'Transportation', subcategory: 'Car Payment'),
  _BudgetSeed(category: 'Transportation', subcategory: 'Car Insurance'),
  _BudgetSeed(category: 'Transportation', subcategory: 'Gas/Fuel'),
  _BudgetSeed(category: 'Transportation', subcategory: 'Car Maintenance'),
  _BudgetSeed(category: 'Transportation', subcategory: 'Parking/Tolls'),
  _BudgetSeed(category: 'Transportation', subcategory: 'Public Transit'),
  _BudgetSeed(category: 'Food', subcategory: 'Groceries'),
  _BudgetSeed(category: 'Food', subcategory: 'Dining Out'),
  _BudgetSeed(category: 'Food', subcategory: 'Coffee/Drinks'),
  _BudgetSeed(category: 'Food', subcategory: 'Takeout/Delivery'),
  _BudgetSeed(category: 'Healthcare', subcategory: 'Health Insurance'),
  _BudgetSeed(category: 'Healthcare', subcategory: 'Doctor/Dentist'),
  _BudgetSeed(category: 'Healthcare', subcategory: 'Prescriptions'),
  _BudgetSeed(category: 'Healthcare', subcategory: 'Vision'),
  _BudgetSeed(category: 'Healthcare', subcategory: 'Gym/Fitness'),
  _BudgetSeed(category: 'Personal', subcategory: 'Clothing'),
  _BudgetSeed(category: 'Personal', subcategory: 'Hair/Beauty'),
  _BudgetSeed(category: 'Personal', subcategory: 'Personal Care'),
  _BudgetSeed(category: 'Personal', subcategory: 'Subscriptions'),
  _BudgetSeed(category: 'Personal', subcategory: 'Entertainment'),
  _BudgetSeed(category: 'Personal', subcategory: 'Hobbies'),
  _BudgetSeed(category: 'Children', subcategory: 'Childcare/Daycare'),
  _BudgetSeed(category: 'Children', subcategory: 'School/Tuition'),
  _BudgetSeed(category: 'Children', subcategory: 'School Supplies'),
  _BudgetSeed(category: 'Children', subcategory: 'Activities/Sports'),
  _BudgetSeed(category: 'Children', subcategory: 'Toys/Clothing'),
  _BudgetSeed(category: 'Savings', subcategory: 'Emergency Fund'),
  _BudgetSeed(category: 'Savings', subcategory: 'Retirement'),
  _BudgetSeed(category: 'Savings', subcategory: 'Investments'),
  _BudgetSeed(category: 'Savings', subcategory: 'Vacation Fund'),
  _BudgetSeed(category: 'Business', subcategory: 'Office Supplies'),
  _BudgetSeed(category: 'Business', subcategory: 'Software/Tools'),
  _BudgetSeed(category: 'Business', subcategory: 'Marketing'),
  _BudgetSeed(category: 'Business', subcategory: 'Professional Services'),
  _BudgetSeed(category: 'Business', subcategory: 'Travel'),
  _BudgetSeed(category: 'Business', subcategory: 'Meals (Business)'),
  _BudgetSeed(category: 'Business', subcategory: 'Equipment'),
  _BudgetSeed(category: 'Business', subcategory: 'Other Business'),
  _BudgetSeed(category: 'Debt', subcategory: 'Credit Card'),
  _BudgetSeed(category: 'Debt', subcategory: 'Student Loan'),
  _BudgetSeed(category: 'Debt', subcategory: 'Personal Loan'),
  _BudgetSeed(category: 'Debt', subcategory: 'Other Debt'),
  _BudgetSeed(category: 'Giving', subcategory: 'Charitable Donations'),
  _BudgetSeed(category: 'Giving', subcategory: 'Church/Tithe'),
  _BudgetSeed(category: 'Giving', subcategory: 'Gifts'),
  _BudgetSeed(category: 'Income', subcategory: 'Salary/Wages'),
  _BudgetSeed(category: 'Income', subcategory: 'Freelance/Side Income'),
  _BudgetSeed(category: 'Income', subcategory: 'Rental Income'),
  _BudgetSeed(category: 'Income', subcategory: 'Investment Income'),
  _BudgetSeed(category: 'Income', subcategory: 'Other Income'),
  _BudgetSeed(category: 'Other', subcategory: 'Miscellaneous'),
];
