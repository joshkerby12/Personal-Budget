import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class OrgService {
  const OrgService(this._supabaseClient);

  static const String _inviteCodeCharacters =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final SupabaseClient _supabaseClient;

  Future<String> createOrg({
    required String name,
    required String userId,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Organization name cannot be empty.');
    }

    // Generate UUID client-side to avoid needing a .select() after insert,
    // which would fail RLS (user is not yet a member when org is created).
    final String orgId = const Uuid().v4();

    await _supabaseClient.from('organizations').insert(<String, dynamic>{
      'id': orgId,
      'name': trimmedName,
      'invite_code': _generateInviteCode(),
    });

    await _supabaseClient.from('org_members').insert(<String, dynamic>{
      'org_id': orgId,
      'profile_id': userId,
      'role': 'owner',
    });

    return orgId;
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
