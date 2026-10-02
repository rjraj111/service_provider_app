/// Configuration and credentials for Supabase backend.
///
/// In production, these should be supplied via `--dart-define` or an environment file.
/// For local testing, placeholder values are provided.
class SupabaseConfig {
  SupabaseConfig._();

  /// The Supabase Project URL (e.g. 'https://your-project.supabase.co')
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qcclticawpjutiqjndta.supabase.co',
  );

  /// The Supabase Anonymous / Publishable public key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_o5etbhbIbJOCuIKkqPnAig_d-37TcpW',
  );

  /// Alias for the publishable public key
  static String get supabasePublishableKey => supabaseAnonKey;

  /// Returns true if the configuration has been updated from the placeholder values.
  static bool get isConfigured {
    return supabaseUrl != 'https://xyzcompany.supabase.co' &&
        !supabaseAnonKey.contains('placeholder-anon-key');
  }
}
