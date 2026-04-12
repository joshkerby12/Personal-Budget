import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../onboarding/data/invite_service.dart';
import '../../data/settings_service.dart';
import '../../models/app_settings.dart';
import '../../models/budget_default.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) {
  return SettingsService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
InviteService settingsInviteService(Ref ref) {
  return InviteService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<String?> settingsOrgId(Ref ref) async {
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
Future<String?> inviteCode(Ref ref, String orgId) async {
  return ref.read(settingsInviteServiceProvider).getInviteCode(orgId);
}

@riverpod
Future<bool> isCurrentUserOwner(Ref ref, String orgId) async {
  final client = ref.watch(supabaseClientProvider);
  final String? userId = client.auth.currentUser?.id;
  if (userId == null) {
    return false;
  }

  final Map<String, dynamic>? row = await client
      .from('org_members')
      .select('role')
      .eq('org_id', orgId)
      .eq('profile_id', userId)
      .maybeSingle();

  return row?['role'] == 'owner';
}

@riverpod
Future<AppSettings?> appSettings(Ref ref, String orgId) async {
  return ref.read(settingsServiceProvider).fetchAppSettings(orgId);
}

@Riverpod(keepAlive: true)
Future<List<BudgetDefault>> budgetDefaults(Ref ref, String orgId) async {
  return ref.read(settingsServiceProvider).ensureGlobalDefaults(orgId);
}

/// Returns a map of category → subcategory → average monthly spend
/// based on the last 3 complete calendar months.
@riverpod
Future<Map<String, Map<String, double>>> spendingAverages(
  Ref ref,
  String orgId,
) async {
  final client = ref.watch(supabaseClientProvider);
  final now = DateTime.now();

  // Start of the month 3 months ago, end of last month
  final from = DateTime(now.year, now.month - 3, 1);
  final to = DateTime(now.year, now.month, 1);

  final String fromStr =
      '${from.year}-${from.month.toString().padLeft(2, '0')}-01';
  final String toStr =
      '${to.year}-${to.month.toString().padLeft(2, '0')}-01';

  final List<dynamic> rows = await client
      .from('transactions')
      .select('id, date, category, subcategory, amount, is_split, transaction_splits(category, subcategory, amount)')
      .eq('org_id', orgId)
      .gte('date', fromStr)
      .lt('date', toStr)
      .neq('category', 'Uncategorized')
      .neq('category', 'Transfers');

  // Accumulate total spend per (category, subcategory, month)
  final Map<String, Map<String, Map<String, double>>> byMonth =
      <String, Map<String, Map<String, double>>>{};

  void accumulate(String category, String subcategory, double amount, String month) {
    if (category.isEmpty || category == 'Uncategorized' || category == 'Transfers') {
      return;
    }
    byMonth
        .putIfAbsent(category, () => <String, Map<String, double>>{})
        .putIfAbsent(subcategory, () => <String, double>{})
        .update(month, (double v) => v + amount, ifAbsent: () => amount);
  }

  for (final dynamic r in rows) {
    final String date = r['date'] as String;
    final String month = date.substring(0, 7); // 'YYYY-MM'
    final bool isSplit = r['is_split'] as bool? ?? false;
    final List<dynamic> splits = r['transaction_splits'] as List<dynamic>? ?? <dynamic>[];

    if (isSplit && splits.isNotEmpty) {
      // Use split amounts — they have the real per-category breakdown
      for (final dynamic s in splits) {
        final String cat = s['category'] as String? ?? '';
        final String sub = s['subcategory'] as String? ?? '';
        final double amt = (s['amount'] as num).toDouble();
        accumulate(cat, sub, amt, month);
      }
    } else {
      final String category = r['category'] as String? ?? '';
      final String subcategory = r['subcategory'] as String? ?? '';
      final double amount = (r['amount'] as num).toDouble();
      accumulate(category, subcategory, amount, month);
    }
  }

  // Average across the 3 months
  final Map<String, Map<String, double>> result =
      <String, Map<String, double>>{};
  for (final MapEntry<String, Map<String, Map<String, double>>> catEntry
      in byMonth.entries) {
    for (final MapEntry<String, Map<String, double>> subEntry
        in catEntry.value.entries) {
      final double total =
          subEntry.value.values.fold(0.0, (double a, double b) => a + b);
      final double avg = total / 3.0;
      result
          .putIfAbsent(catEntry.key, () => <String, double>{})[subEntry.key] =
          avg;
    }
  }

  return result;
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> saveIrsRate(String orgId, double rate) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      final SettingsService service = ref.read(settingsServiceProvider);
      final AppSettings? existing = await service.fetchAppSettings(orgId);
      await service.saveAppSettings(
        AppSettings(id: existing?.id ?? '', orgId: orgId, irsRatePerMile: rate),
      );
      ref.invalidate(appSettingsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> saveBudgets(
    String orgId,
    List<BudgetDefault> defaults, {
    List<String> deleteIds = const <String>[],
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref
          .read(settingsServiceProvider)
          .saveBudgetDefaults(defaults, deleteIds: deleteIds);
      ref.invalidate(budgetDefaultsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteDefault(String orgId, String id) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsServiceProvider).deleteBudgetDefault(id);
      ref.invalidate(budgetDefaultsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> resetGlobalDefaults(String orgId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsServiceProvider).resetGlobalDefaults(orgId);
      ref.invalidate(budgetDefaultsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<Map<String, dynamic>> exportData(String orgId) async {
    final SettingsService service = ref.read(settingsServiceProvider);
    return service.exportSettingsData(orgId);
  }

  Future<void> importData(String orgId, Map<String, dynamic> payload) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref
          .read(settingsServiceProvider)
          .importSettingsData(orgId, payload);
      ref
        ..invalidate(appSettingsProvider(orgId))
        ..invalidate(budgetDefaultsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}
