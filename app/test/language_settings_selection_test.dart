import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/settings/models/app_language.dart';
import 'package:talklog/features/settings/models/language_settings_selection.dart';

void main() {
  group('LanguageSettingsSelection cloud synchronization', () {
    test('round-trips stable language codes', () {
      const localSelection = LanguageSettingsSelection(
        baseLocale: AppLanguage.spanish,
        learningLanguage: AppLanguage.simplifiedChinese,
      );

      final cloudValues = localSelection.toCloudValues();
      final restored = LanguageSettingsSelection.fromCloudRow(cloudValues);

      expect(cloudValues, {
        'base_locale': 'es',
        'learning_language': 'zh-Hans',
      });
      expect(restored, isNotNull);
      expect(restored!.baseLocale, AppLanguage.spanish);
      expect(restored.learningLanguage, AppLanguage.simplifiedChinese);
    });

    test('accepts legacy values returned from an existing cloud row', () {
      final restored = LanguageSettingsSelection.fromCloudRow({
        'base_locale': '日本語',
        'learning_language': '中国語',
      });

      expect(restored, isNotNull);
      expect(restored!.toCloudValues(), {
        'base_locale': 'ja',
        'learning_language': 'zh-Hans',
      });
    });

    test('rejects incomplete and unsupported cloud rows', () {
      expect(
        LanguageSettingsSelection.fromCloudRow({'base_locale': 'en'}),
        isNull,
      );
      expect(
        LanguageSettingsSelection.fromCloudRow({
          'base_locale': 'fr',
          'learning_language': 'ja',
        }),
        isNull,
      );
    });

    test('rejects a cloud row with conflicting languages', () {
      expect(
        LanguageSettingsSelection.fromCloudRow({
          'base_locale': 'es',
          'learning_language': 'es',
        }),
        isNull,
      );
    });
  });
}
