import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class InviteService {
  const InviteService(this._client);

  static const String _inviteCodeCharacters =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final SupabaseClient _client;

  Future<({String orgId, String orgName})?> findOrgByCode(String code) async {
    final String normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      return null;
    }

    final Map<String, dynamic>? row = await _client
        .from('organizations')
        .select('id, name')
        .eq('invite_code', normalizedCode)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return (orgId: row['id'] as String, orgName: row['name'] as String);
  }

  Future<void> joinOrg({required String orgId, required String userId}) async {
    await _client.from('org_members').insert(<String, dynamic>{
      'org_id': orgId,
      'profile_id': userId,
      'role': 'member',
    });
  }

  Future<String?> getInviteCode(String orgId) async {
    final Map<String, dynamic>? row = await _client
        .from('organizations')
        .select('invite_code')
        .eq('id', orgId)
        .maybeSingle();

    return row?['invite_code'] as String?;
  }

  Future<String> regenerateCode(String orgId) async {
    final String newCode = _generateInviteCode();
    await _client
        .from('organizations')
        .update(<String, dynamic>{'invite_code': newCode})
        .eq('id', orgId);
    return newCode;
  }

  String _generateInviteCode() {
    final Random random = Random.secure();
    return List<String>.generate(
      6,
      (_) =>
          _inviteCodeCharacters[random.nextInt(_inviteCodeCharacters.length)],
    ).join();
  }
}
