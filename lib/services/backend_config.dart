class BackendConfig {
  const BackendConfig._();

  static const String supabaseUrl = 'https://urjbzchoxkafnhkydbyr.supabase.co';

  static const String supabasePublishableKey =
      'sb_publishable_2vZpwTWhhFTPvrxhCYtJEQ_naG188Li';

  static bool get isConfigured {
    final uri = Uri.tryParse(supabaseUrl);

    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        supabasePublishableKey.trim().isNotEmpty;
  }
}
