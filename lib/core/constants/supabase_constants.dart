import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  const SupabaseConstants._();

  static const String supabaseUrlEnvKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyEnvKey = 'SUPABASE_ANON_KEY';

  static String get supabaseUrl => _requireEnvValue(supabaseUrlEnvKey);
  static String get supabaseAnonKey => _requireEnvValue(supabaseAnonKeyEnvKey);

  static String _requireEnvValue(String key) {
    final String? value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required .env value: $key');
    }
    return value;
  }
}
