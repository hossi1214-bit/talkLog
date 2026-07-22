import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettingsStore language persistence', () {
    test('restores stable language codes', () async {
      SharedPreferences.setMockInitialValues({
        'base_locale': 'es',
        'learning_language': 'zh-Hans',
      });
      final store = AppSettingsStore.forTesting();

      await store.load();

      expect(store.baseLocaleCode, 'es');
      expect(store.learningLanguageCode, 'zh-Hans');
    });

    test('migrates legacy labels to stable codes while loading', () async {
      SharedPreferences.setMockInitialValues({
        'base_locale': '日本語',
        'learning_language': '中国語',
      });
      final store = AppSettingsStore.forTesting();

      await store.load();

      final preferences = await SharedPreferences.getInstance();
      expect(store.baseLocaleCode, 'ja');
      expect(store.learningLanguageCode, 'zh-Hans');
      expect(preferences.getString('base_locale'), 'ja');
      expect(preferences.getString('learning_language'), 'zh-Hans');
    });

    test('saves changed languages as stable codes and restores them', () async {
      SharedPreferences.setMockInitialValues({
        'base_locale': 'en',
        'learning_language': 'es',
      });
      final writer = AppSettingsStore.forTesting();
      await writer.load();

      expect(
        await writer.setLanguages(baseLocale: 'ja', learningLanguage: 'ko'),
        isTrue,
      );

      final reader = AppSettingsStore.forTesting();
      await reader.load();
      expect(reader.baseLocaleCode, 'ja');
      expect(reader.learningLanguageCode, 'ko');
    });
  });

  group('AppSettingsStore language conflict prevention', () {
    test(
      'rejects changing the learning language to the app language',
      () async {
        SharedPreferences.setMockInitialValues({
          'base_locale': 'en',
          'learning_language': 'es',
        });
        final store = AppSettingsStore.forTesting();
        await store.load();

        expect(await store.setLearningLanguage('en'), isFalse);
        expect(store.baseLocaleCode, 'en');
        expect(store.learningLanguageCode, 'es');

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getString('base_locale'), 'en');
        expect(preferences.getString('learning_language'), 'es');
      },
    );

    test(
      'rejects changing the app language to the learning language',
      () async {
        SharedPreferences.setMockInitialValues({
          'base_locale': 'ja',
          'learning_language': 'ko',
        });
        final store = AppSettingsStore.forTesting();
        await store.load();

        expect(await store.setBaseLocale('ko'), isFalse);
        expect(store.baseLocaleCode, 'ja');
        expect(store.learningLanguageCode, 'ko');
      },
    );

    test(
      'rejects an invalid pair atomically without saving either value',
      () async {
        SharedPreferences.setMockInitialValues({
          'base_locale': 'en',
          'learning_language': 'ja',
        });
        final store = AppSettingsStore.forTesting();
        await store.load();

        expect(
          await store.setLanguages(baseLocale: 'es', learningLanguage: 'es'),
          isFalse,
        );
        expect(store.baseLocaleCode, 'en');
        expect(store.learningLanguageCode, 'ja');

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.getString('base_locale'), 'en');
        expect(preferences.getString('learning_language'), 'ja');
      },
    );

    test('repairs a conflicting saved pair during migration', () async {
      SharedPreferences.setMockInitialValues({
        'base_locale': 'es',
        'learning_language': 'es',
      });
      final store = AppSettingsStore.forTesting();

      await store.load();

      expect(store.baseLocaleCode, 'es');
      expect(store.learningLanguageCode, 'ja');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('learning_language'), 'ja');
    });
  });
}
