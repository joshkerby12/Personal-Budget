import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/invite_service.dart';
import '../../data/org_service.dart';

part 'onboarding_provider.g.dart';

@Riverpod(keepAlive: true)
OrgService orgService(Ref ref) {
  return OrgService(ref.watch(supabaseClientProvider));
}

@Riverpod(keepAlive: true)
InviteService inviteService(Ref ref) {
  return InviteService(ref.watch(supabaseClientProvider));
}

@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> createOrganization(String name) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Organization name cannot be empty.');
    }

    final String? userId = ref
        .read(supabaseClientProvider)
        .auth
        .currentUser
        ?.id;
    if (userId == null) {
      throw StateError('You must be signed in to create an organization.');
    }

    state = const AsyncLoading<void>();
    final AsyncValue<void> nextState = await AsyncValue.guard(() async {
      final String orgId = await ref
          .read(orgServiceProvider)
          .createOrg(name: trimmedName, userId: userId);
      await ref.read(categoryServiceProvider).seedDefaultCategories(orgId);
      await ref.read(settingsServiceProvider).resetGlobalDefaults(orgId);
    });
    state = nextState;

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<({String orgId, String orgName})?> findOrgByInviteCode(
    String code,
  ) async {
    final InviteService service = ref.read(inviteServiceProvider);
    return service.findOrgByCode(code);
  }

  Future<void> joinOrganization({
    required String orgId,
    required String userId,
  }) async {
    state = const AsyncLoading<void>();
    final AsyncValue<void> nextState = await AsyncValue.guard(() async {
      await ref
          .read(inviteServiceProvider)
          .joinOrg(orgId: orgId, userId: userId);
    });
    state = nextState;

    if (state.hasError) {
      throw state.error!;
    }
  }
}
