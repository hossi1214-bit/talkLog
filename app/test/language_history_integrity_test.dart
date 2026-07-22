import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/correction/models/ai_correction_result.dart';
import 'package:talklog/features/recording/models/record_entry.dart';

void main() {
  test(
    'past recording and correction retain their original language context',
    () {
      final originalEntry = RecordEntry(
        id: 'past-recording',
        createdAt: DateTime.utc(2026, 7, 23),
        duration: const Duration(seconds: 30),
        audioPath: 'past-recording.m4a',
        language: 'es',
      );
      const originalCorrection = AiCorrectionResult(
        transcript: 'Hola',
        correctedText: 'Hola.',
        naturalExpression: '¡Hola!',
        translation: 'こんにちは',
        grammarNotes: ['日本語の文法解説'],
        vocabularyNotes: ['hola: こんにちは'],
        score: 90,
        encouragement: 'よくできました。',
        learningLanguage: 'es',
        baseLocale: 'ja',
        promptVersion: AiCorrectionResult.currentPromptVersion,
      );

      final restoredEntry = RecordEntry.fromJson(originalEntry.toJson());
      final restoredCorrection = AiCorrectionResult.fromJson(
        originalCorrection.toJson(),
      );

      expect(restoredEntry.language, 'es');
      expect(restoredCorrection.learningLanguage, 'es');
      expect(restoredCorrection.baseLocale, 'ja');
      expect(
        restoredCorrection.matchesContext(
          learningLanguage: restoredEntry.language,
          baseLocale: 'ja',
        ),
        isTrue,
      );
      expect(
        restoredCorrection.matchesContext(
          learningLanguage: 'fr',
          baseLocale: 'en',
        ),
        isFalse,
      );
    },
  );
}
