import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthService {
  const AuthService(this._supabaseClient);

  final supa.SupabaseClient _supabaseClient;

  Future<void> signIn({required String email, required String password}) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: <String, dynamic>{'full_name': fullName.trim()},
    );
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _supabaseClient.auth.resetPasswordForEmail(email.trim());
  }
}
