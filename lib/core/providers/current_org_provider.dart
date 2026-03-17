import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/supabase_client_provider.dart';

part 'current_org_provider.g.dart';

@riverpod
Future<String?> currentOrgId(Ref ref) async {
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
