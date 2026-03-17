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
