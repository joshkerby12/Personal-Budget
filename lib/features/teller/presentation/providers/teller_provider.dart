import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/teller_service.dart';
import '../../models/teller_enrollment.dart';

part 'teller_provider.g.dart';

@Riverpod(keepAlive: true)
TellerService tellerService(Ref ref) {
  return TellerService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<List<TellerEnrollment>> tellerEnrollments(Ref ref, String orgId) async {
  return ref.read(tellerServiceProvider).fetchEnrollments(orgId);
}

@riverpod
class TellerController extends _$TellerController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> enroll(
    String orgId,
    String enrollmentId,
    String accessToken,
  ) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref
          .read(tellerServiceProvider)
          .enroll(
            orgId: orgId,
            enrollmentId: enrollmentId,
            accessToken: accessToken,
          );
      ref.invalidate(tellerEnrollmentsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<int> syncNow(String orgId, String enrollmentId) async {
    state = const AsyncLoading<void>();
    int imported = 0;

    state = await AsyncValue.guard(() async {
      imported = await ref
          .read(tellerServiceProvider)
          .syncNow(orgId, enrollmentId);
      ref.invalidate(tellerEnrollmentsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }

    return imported;
  }

  Future<void> disconnect(String orgId, String enrollmentId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref.read(tellerServiceProvider).disconnect(enrollmentId);
      ref.invalidate(tellerEnrollmentsProvider(orgId));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}
