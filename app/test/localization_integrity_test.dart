import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Japanese and Spanish ARB files contain the same messages as English',
    () {
      final arbFiles = <String, File>{
        'en': File('lib/l10n/app_en.arb'),
        'ja': File('lib/l10n/app_ja.arb'),
        'es': File('lib/l10n/app_es.arb'),
      };

      final keysByLocale = arbFiles.map((locale, file) {
        expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        return MapEntry(
          locale,
          json.keys.where((key) => !key.startsWith('@')).toSet(),
        );
      });

      final sourceKeys = keysByLocale['en']!;
      for (final locale in const ['ja', 'es']) {
        final localeKeys = keysByLocale[locale]!;
        expect(
          localeKeys.difference(sourceKeys),
          isEmpty,
          reason: '$locale has keys that are missing from en',
        );
        expect(
          sourceKeys.difference(localeKeys),
          isEmpty,
          reason: '$locale is missing translated message keys',
        );
      }
    },
  );

  test('major screens and errors are translated in all three ARB files', () {
    const requiredKeys = {
      'navHome',
      'recordTitle',
      'historyTitle',
      'vocabularyTitle',
      'progressTitle',
      'settingsTitle',
      'premiumTitle',
      'aiCorrectionTitle',
      'noRecognizableSpeech',
      'unsupportedCorrectionLanguage',
      'analysisFailed',
      'correctionAuthRequired',
      'networkError',
      'invalidServerResponse',
      'dailyAiLimitReached',
    };
    final messages = <String, Map<String, dynamic>>{};
    for (final locale in const ['en', 'ja', 'es']) {
      messages[locale] =
          jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      for (final key in requiredKeys) {
        expect(
          messages[locale]![key]?.toString().trim(),
          isNotEmpty,
          reason: '$locale is missing a translation for $key',
        );
      }
    }

    for (final locale in const ['ja', 'es']) {
      for (final key in requiredKeys.difference({'premiumTitle'})) {
        expect(
          messages[locale]![key],
          isNot(messages['en']![key]),
          reason: '$locale still uses the English value for $key',
        );
      }
    }
  });
}
