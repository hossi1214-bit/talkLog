import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/settings/models/app_language.dart';

void main() {
  group('AppLanguage', () {
    test('parses stable codes and legacy Japanese labels', () {
      expect(AppLanguage.parse('ja'), AppLanguage.japanese);
      expect(AppLanguage.parse('日本語'), AppLanguage.japanese);
      expect(AppLanguage.parse('zh-Hans'), AppLanguage.simplifiedChinese);
      expect(AppLanguage.parse('中国語'), AppLanguage.simplifiedChinese);
      expect(AppLanguage.parse('unsupported'), isNull);
    });

    test('base locales are Japanese, English, and Spanish', () {
      expect(supportedBaseLocales, {
        AppLanguage.japanese,
        AppLanguage.english,
        AppLanguage.spanish,
      });
    });

    test('supports exactly eight learning languages', () {
      expect(supportedLearningLanguages, {
        AppLanguage.japanese,
        AppLanguage.english,
        AppLanguage.spanish,
        AppLanguage.french,
        AppLanguage.german,
        AppLanguage.italian,
        AppLanguage.korean,
        AppLanguage.simplifiedChinese,
      });
    });

    test('excludes the base locale from learning languages', () {
      final languages = availableLearningLanguagesFor(AppLanguage.japanese);

      expect(languages, isNot(contains(AppLanguage.japanese)));
      expect(languages, contains(AppLanguage.english));
      expect(languages, contains(AppLanguage.simplifiedChinese));
      expect(languages, hasLength(AppLanguage.values.length - 1));
    });

    test('rejects selecting the same base and learning language', () {
      expect(
        isValidLanguageSelection(
          baseLocale: AppLanguage.spanish,
          learningLanguage: AppLanguage.spanish,
        ),
        isFalse,
      );
      expect(
        isValidLanguageSelection(
          baseLocale: AppLanguage.spanish,
          learningLanguage: AppLanguage.french,
        ),
        isTrue,
      );
    });

    test('uses a supported device locale and falls back to English', () {
      expect(preferredBaseLocaleFor('ja-JP'), AppLanguage.japanese);
      expect(preferredBaseLocaleFor('es_MX'), AppLanguage.spanish);
      expect(preferredBaseLocaleFor('en-US'), AppLanguage.english);
      expect(preferredBaseLocaleFor('fr-FR'), AppLanguage.english);
    });

    test('uses device locale and Spanish for a new user', () {
      final selection = resolveInitialLanguageSelection(
        deviceLanguageTag: 'ja-JP',
      );

      expect(selection.baseLocale, AppLanguage.japanese);
      expect(selection.learningLanguage, AppLanguage.spanish);
    });

    test('avoids a Spanish base and learning language conflict', () {
      final selection = resolveInitialLanguageSelection(
        deviceLanguageTag: 'es-MX',
      );

      expect(selection.baseLocale, AppLanguage.spanish);
      expect(selection.learningLanguage, AppLanguage.japanese);
    });

    test('migrates legacy Japanese labels and preserves the selection', () {
      final selection = resolveInitialLanguageSelection(
        deviceLanguageTag: 'en-US',
        savedBaseLocale: '日本語',
        savedLearningLanguage: '中国語',
      );

      expect(selection.baseLocale, AppLanguage.japanese);
      expect(selection.learningLanguage, AppLanguage.simplifiedChinese);
    });

    test('replaces invalid saved values with safe defaults', () {
      final selection = resolveInitialLanguageSelection(
        deviceLanguageTag: 'fr-FR',
        savedBaseLocale: 'fr',
        savedLearningLanguage: 'unsupported',
      );

      expect(selection.baseLocale, AppLanguage.english);
      expect(selection.learningLanguage, AppLanguage.spanish);
    });
  });
}
