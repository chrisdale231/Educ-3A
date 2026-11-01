/** Public client configuration only. Never put a service-role key here. */
export const backendConfig = {
  url: 'https://urjbzchoxkafnhkydbyr.supabase.co',
  anonKey: 'sb_publishable_2vZpwTWhhFTPvrxhCYtJEQ_naG188Li',
};

export const backendConfigured =
  backendConfig.url.startsWith('https://') && backendConfig.anonKey.length > 20;
