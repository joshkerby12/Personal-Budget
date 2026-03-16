import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_client_provider.dart';
import '../../data/auth_service.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService(ref.watch(supabaseClientProvider));
}

@riverpod
Stream<Session?> authStateChanges(Ref ref) async* {
  final SupabaseClient client = ref.watch(supabaseClientProvider);
  yield client.auth.currentSession;

  await for (final AuthState state in client.auth.onAuthStateChange) {
    yield state.session;
  }
}
