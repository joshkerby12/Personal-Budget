import 'package:supabase_flutter/supabase_flutter.dart' show FunctionResponse, SupabaseClient;

import '../models/teller_enrollment.dart';

class TellerService {
  const TellerService(this._client);

  final SupabaseClient _client;

  Future<List<TellerEnrollment>> fetchEnrollments(String orgId) async {
    final List<dynamic> rows = await _client
        .from('teller_enrollments')
        .select(
          'id, org_id, profile_id, teller_enrollment_id, institution_name, '
          'account_name, account_last_four, account_type, account_subtype, '
          'last_synced_at, is_active, created_at',
        )
        .eq('org_id', orgId)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    return rows
        .cast<Map<String, dynamic>>()
        .map(TellerEnrollment.fromJson)
        .toList(growable: false);
  }

  Future<void> enroll({
    required String orgId,
    required String enrollmentId,
    required String accessToken,
  }) async {
    await _client.functions.invoke(
      'teller-enroll',
      body: <String, dynamic>{
        'enrollmentId': enrollmentId,
        'accessToken': accessToken,
        'orgId': orgId,
      },
    );
  }

  Future<int> syncNow(String orgId, String enrollmentId) async {
    final FunctionResponse response = await _client.functions.invoke(
      'teller-sync',
      body: <String, dynamic>{'orgId': orgId, 'enrollmentId': enrollmentId},
    );

    final dynamic data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['imported'] as int?) ?? 0;
    }
    if (data is Map) {
      return (data['imported'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> disconnect(String enrollmentId) async {
    await _client.functions.invoke(
      'teller-disconnect',
      body: <String, dynamic>{'enrollmentId': enrollmentId},
    );
  }
}
