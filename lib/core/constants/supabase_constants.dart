import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  const SupabaseConstants._();

  static const String supabaseUrlEnvKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyEnvKey = 'SUPABASE_ANON_KEY';
  static const String tellerAppIdEnvKey = 'TELLER_APP_ID';

  static String get supabaseUrl => _requireEnvValue(supabaseUrlEnvKey);
  static String get supabaseAnonKey => _requireEnvValue(supabaseAnonKeyEnvKey);
  static String? get tellerAppId => _optionalEnvValue(tellerAppIdEnvKey);

  static String _requireEnvValue(String key) {
    final String? value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing required .env value: $key');
    }
    return value;
  }

  static String? _optionalEnvValue(String key) {
    final String? value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
