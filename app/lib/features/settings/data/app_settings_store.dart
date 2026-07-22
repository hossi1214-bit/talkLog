import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/app_language.dart';
import '../models/language_settings_selection.dart';

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._();

  @visibleForTesting
  AppSettingsStore.forTesting();

  static final AppSettingsStore instance = AppSettingsStore._();

  static const _baseLocaleKey = 'base_locale';
  static const _learningLanguageKey = 'learning_language';

  // Kept temporarily for existing screens. UI localization will replace these
  // Japanese labels with locale-aware labels in the next implementation phase.
  static List<String> get supportedLanguages => supportedLearningLanguages
      .map((language) => language.japaneseLabel)
      .toList(growable: false);

  bool _isLoaded = false;
  bool _isCloudSyncing = false;
  AppLanguage _baseLocale = AppLanguage.english;
  AppLanguage _learningLanguage = AppLanguage.spanish;
  String? _cloudMessage;
  String? _cloudError;

  bool get isLoaded => _isLoaded;
  bool get isCloudSyncing => _isCloudSyncing;
  AppLanguage get baseLocale => _baseLocale;
  String get baseLocaleCode => _baseLocale.code;
  AppLanguage get learningLanguageValue => _learningLanguage;
  String get learningLanguageCode => _learningLanguage.code;
  String get learningLanguage => _learningLanguage.japaneseLabel;
  String? get cloudMessage => _cloudMessage;
  String? get cloudError => _cloudError;

  List<AppLanguage> get availableLearningLanguages =>
      availableLearningLanguagesFor(_baseLocale);

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final initialSelection = resolveInitialLanguageSelection(
      deviceLanguageTag: PlatformDispatcher.instance.locale.toLanguageTag(),
      savedBaseLocale: prefs.getString(_baseLocaleKey),
      savedLearningLanguage: prefs.getString(_learningLanguageKey),
    );
    _baseLocale = initialSelection.baseLocale;
    _learningLanguage = initialSelection.learningLanguage;
    await _persistLocal(prefs);

    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> setBaseLocale(String locale) async {
    await load();
    final nextLocale = AppLanguage.parse(locale);
    if (nextLocale == null ||
        !supportedBaseLocales.contains(nextLocale) ||
        nextLocale == _learningLanguage) {
      return false;
    }
    if (nextLocale == _baseLocale) {
      return true;
    }

    _baseLocale = nextLocale;
    await _persistLocal();
    notifyListeners();
    await syncToCloud();
    return true;
  }

  Future<bool> setLearningLanguage(String language) async {
    await load();
    final nextLanguage = AppLanguage.parse(language);
    if (nextLanguage == null ||
        !supportedLearningLanguages.contains(nextLanguage) ||
        nextLanguage == _baseLocale) {
      return false;
    }
    if (nextLanguage == _learningLanguage) {
      return true;
    }

    _learningLanguage = nextLanguage;
    await _persistLocal();
    notifyListeners();
    await syncToCloud();
    return true;
  }

  Future<bool> setLanguages({
    required String baseLocale,
    required String learningLanguage,
  }) async {
    await load();
    final nextBaseLocale = AppLanguage.parse(baseLocale);
    final nextLearningLanguage = AppLanguage.parse(learningLanguage);
    if (nextBaseLocale == null ||
        nextLearningLanguage == null ||
        !supportedBaseLocales.contains(nextBaseLocale) ||
        !supportedLearningLanguages.contains(nextLearningLanguage) ||
        nextBaseLocale == nextLearningLanguage) {
      return false;
    }

    if (nextBaseLocale == _baseLocale &&
        nextLearningLanguage == _learningLanguage) {
      return true;
    }

    _baseLocale = nextBaseLocale;
    _learningLanguage = nextLearningLanguage;
    await _persistLocal();
    notifyListeners();
    await syncToCloud();
    return true;
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
          .select('base_locale, learning_language')
          .eq('user_id', userId)
          .maybeSingle();
      final cloudSelection = LanguageSettingsSelection.fromCloudRow(row);
      if (cloudSelection != null) {
        _baseLocale = cloudSelection.baseLocale;
        _learningLanguage = cloudSelection.learningLanguage;
        await _persistLocal();
      }
      _cloudMessage = 'SETTINGS_DOWNLOADED';
    } catch (error) {
      _cloudError = 'SETTINGS_DOWNLOAD_FAILED|${_friendlyError(error)}';
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
      final selection = LanguageSettingsSelection(
        baseLocale: _baseLocale,
        learningLanguage: _learningLanguage,
      );
      await client.from('settings').upsert({
        'user_id': userId,
        ...selection.toCloudValues(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id');
      _cloudMessage = 'SETTINGS_SAVED';
    } catch (error) {
      _cloudError = 'SETTINGS_SAVE_FAILED|${_friendlyError(error)}';
    } finally {
      _isCloudSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _persistLocal([SharedPreferences? preferences]) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    await prefs.setString(_baseLocaleKey, _baseLocale.code);
    await prefs.setString(_learningLanguageKey, _learningLanguage.code);
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
