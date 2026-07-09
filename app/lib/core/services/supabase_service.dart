import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  SupabaseService._();

  static bool _isInitialized = false;

  static bool get isConfigured => SupabaseConfig.isConfigured;
  static bool get isInitialized => _isInitialized;

  static SupabaseClient? get client {
    if (!_isInitialized) {
      return null;
    }
    return Supabase.instance.client;
  }

  static Future<void> initializeIfConfigured() async {
    if (_isInitialized || !SupabaseConfig.isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      debug: kDebugMode,
    );
    _isInitialized = true;
  }
}
