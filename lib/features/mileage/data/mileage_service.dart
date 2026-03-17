import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/mileage_trip.dart';

class MileageService {
  const MileageService(this._client);

  final SupabaseClient _client;

  Future<List<MileageTrip>> fetchTrips(
    String orgId, {
    int? year,
    int? month,
  }) async {
    dynamic query = _client.from('mileage_trips').select().eq('org_id', orgId);

    if (year != null && month != null) {
      final DateTime start = DateTime(year, month, 1);
      final DateTime end = DateTime(year, month + 1, 1);
      query = query.gte('date', _dateOnly(start)).lt('date', _dateOnly(end));
    } else if (year != null) {
      final DateTime start = DateTime(year, 1, 1);
      final DateTime end = DateTime(year + 1, 1, 1);
      query = query.gte('date', _dateOnly(start)).lt('date', _dateOnly(end));
    }

    final List<dynamic> rows = await query.order('date', ascending: false);
    return rows
        .cast<Map<String, dynamic>>()
        .map(MileageTrip.fromJson)
        .toList(growable: false);
  }

  Future<void> insertTrip(MileageTrip trip) async {
    final String? userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save a trip.');
    }

    await _client.from('mileage_trips').insert(<String, dynamic>{
      'org_id': trip.orgId,
      'created_by': userId,
      'date': _dateOnly(trip.date),
      'purpose': trip.purpose,
      'from_address': trip.fromAddress,
      'to_address': trip.toAddress,
      'one_way_miles': trip.oneWayMiles,
      'is_round_trip': trip.isRoundTrip,
      'biz_pct': trip.bizPct,
      'category': trip.category,
    });
  }

  Future<void> updateTrip(MileageTrip trip) async {
    await _client
        .from('mileage_trips')
        .update(<String, dynamic>{
          'date': _dateOnly(trip.date),
          'purpose': trip.purpose,
          'from_address': trip.fromAddress,
          'to_address': trip.toAddress,
          'one_way_miles': trip.oneWayMiles,
          'is_round_trip': trip.isRoundTrip,
          'biz_pct': trip.bizPct,
          'category': trip.category,
        })
        .eq('id', trip.id);
  }

  Future<void> deleteTrip(String tripId) async {
    await _client.from('mileage_trips').delete().eq('id', tripId);
  }
}

String _dateOnly(DateTime date) => date.toIso8601String().split('T').first;
