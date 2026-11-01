import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';
import { backendConfig, backendConfigured } from '../config';

export const supabase = backendConfigured
  ? createClient(backendConfig.url, backendConfig.anonKey, {
      auth: {
        storage: AsyncStorage,
        persistSession: true,
        autoRefreshToken: true,
      },
    })
  : undefined;
