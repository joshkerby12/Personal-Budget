import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/mileage_service.dart';
import '../../models/mileage_trip.dart';

part 'mileage_provider.g.dart';

@Riverpod(keepAlive: true)
MileageService mileageService(Ref ref) {
  return MileageService(ref.watch(supabaseClientProvider));
}

@riverpod
Future<String?> mileageOrgId(Ref ref) async {
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
class MileageController extends _$MileageController {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  Future<void> saveTrip(MileageTrip trip, {bool isEdit = false}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      if (isEdit) {
        await ref.read(mileageServiceProvider).updateTrip(trip);
      } else {
        await ref.read(mileageServiceProvider).insertTrip(trip);
      }
      ref.invalidate(mileageTripsProvider);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> deleteTrip(String tripId) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await ref.read(mileageServiceProvider).deleteTrip(tripId);
      ref.invalidate(mileageTripsProvider);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

@riverpod
Future<List<MileageTrip>> mileageTrips(
  Ref ref,
  String orgId, {
  int? year,
  int? month,
}) async {
  return ref
      .read(mileageServiceProvider)
      .fetchTrips(orgId, year: year, month: month);
}
