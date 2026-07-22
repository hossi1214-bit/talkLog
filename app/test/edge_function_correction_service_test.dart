import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/correction/services/edge_function_correction_service.dart';
import 'package:talklog/features/recording/models/record_entry.dart';
import 'package:talklog/features/settings/models/app_language.dart';

void main() {
  test('sends learning and explanation languages separately', () {
    final entry = RecordEntry(
      id: 'recording-1',
      createdAt: DateTime.utc(2026, 7, 22),
      duration: const Duration(seconds: 30),
      audioPath: 'user/recording-1.m4a',
      language: 'zh-Hans',
    );

    final body = EdgeFunctionCorrectionService.requestBodyFor(
      entry,
      baseLocale: 'es',
    );

    expect(body['recordingId'], 'recording-1');
    expect(body['learningLanguage'], 'zh-Hans');
    expect(body['baseLocale'], 'es');
    expect(body['language'], 'zh-Hans');
  });

  test('builds requests for every valid learning and explanation pair', () {
    var validPairCount = 0;

    for (final baseLocale in supportedBaseLocales) {
      for (final learningLanguage in supportedLearningLanguages) {
        if (baseLocale == learningLanguage) {
          continue;
        }
        final entry = RecordEntry(
          id: 'recording-$validPairCount',
          createdAt: DateTime.utc(2026, 7, 23),
          duration: const Duration(seconds: 10),
          audioPath: 'user/recording-$validPairCount.m4a',
          language: learningLanguage.code,
        );

        final body = EdgeFunctionCorrectionService.requestBodyFor(
          entry,
          baseLocale: baseLocale.code,
        );

        expect(body['learningLanguage'], learningLanguage.code);
        expect(body['baseLocale'], baseLocale.code);
        validPairCount++;
      }
    }

    expect(validPairCount, 21);
  });

  test('rejects the three same-language combinations before sending', () {
    for (final language in supportedBaseLocales) {
      final entry = RecordEntry(
        id: 'recording-${language.code}',
        createdAt: DateTime.utc(2026, 7, 23),
        duration: const Duration(seconds: 10),
        audioPath: 'user/recording-${language.code}.m4a',
        language: language.code,
      );

      expect(
        () => EdgeFunctionCorrectionService.requestBodyFor(
          entry,
          baseLocale: language.code,
        ),
        throwsArgumentError,
      );
    }
  });

  test('sends a stable code for a legacy recording language label', () {
    final entry = RecordEntry(
      id: 'legacy-spanish-recording',
      createdAt: DateTime.utc(2026, 7, 23),
      duration: const Duration(seconds: 10),
      audioPath: 'recording.m4a',
      language: 'スペイン語',
    );

    final body = EdgeFunctionCorrectionService.requestBodyFor(
      entry,
      baseLocale: 'ja',
    );

    expect(body['learningLanguage'], 'es');
    expect(body['language'], 'es');
  });
}
