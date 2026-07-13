import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._();

  static final AppSettingsStore instance = AppSettingsStore._();

  static const supportedLanguages = [
    '英語',
    'スペイン語',
    'フランス語',
    'ドイツ語',
    'イタリア語',
    '韓国語',
    '中国語',
  ];
  static const _languageKey = 'learning_language';
  static const _defaultLanguage = '英語';

  bool _isLoaded = false;
  bool _isCloudSyncing = false;
  String _learningLanguage = _defaultLanguage;
  String? _cloudMessage;
  String? _cloudError;

  bool get isLoaded => _isLoaded;
  bool get isCloudSyncing => _isCloudSyncing;
  String get learningLanguage => _learningLanguage;
  String? get cloudMessage => _cloudMessage;
  String? get cloudError => _cloudError;

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null && supportedLanguages.contains(savedLanguage)) {
      _learningLanguage = savedLanguage;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setLearningLanguage(String language) async {
    if (!supportedLanguages.contains(language) ||
        language == _learningLanguage) {
      return;
    }

    _learningLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    _isLoaded = true;
    notifyListeners();
    await syncToCloud();
  }

  Future<void> syncFromCloud() async {
    await load();
    final client = SupabaseService.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null || _isCloudSyncing) {
      return;
    }

    _isCloudSyncing = true;
    _cloudError = null;
    notifyListeners();

    try {
      final row = await client
          .from('settings')
          .select('learning_language')
          .eq('user_id', userId)
          .maybeSingle();
      final language = row?['learning_language'] as String?;
      if (language != null && supportedLanguages.contains(language)) {
        _learningLanguage = language;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, language);
      }
      _cloudMessage = '設定をクラウドから読み込みました。';
    } catch (error) {
      _cloudError = _friendlyError(error);
    } finally {
      _isCloudSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncToCloud() async {
    await load();
    final client = SupabaseService.client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null || _isCloudSyncing) {
      return;
    }

    _isCloudSyncing = true;
    _cloudError = null;
    notifyListeners();

    try {
      await _ensureProfile(client, userId);
      await client.from('settings').upsert({
        'user_id': userId,
        'learning_language': _learningLanguage,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
      _cloudMessage = '設定をクラウドに保存しました。';
    } catch (error) {
      _cloudError = _friendlyError(error);
    } finally {
      _isCloudSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _ensureProfile(SupabaseClient client, String userId) async {
    final user = client.auth.currentUser;
    await client.from('profiles').upsert({
      'id': userId,
      'email': user?.email,
      'display_name': user?.email ?? '匿名ユーザー',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 160) {
      return message;
    }
    return '${message.substring(0, 160)}...';
  }
}
