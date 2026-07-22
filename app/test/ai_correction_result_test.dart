import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/correction/models/ai_correction_result.dart';

void main() {
  test('reads the language-independent translation key', () {
    final result = AiCorrectionResult.fromJson({
      'transcript': 'Hello',
      'correctedText': 'Hello.',
      'naturalExpression': 'Hi!',
      'translation': 'Hola',
      'grammarNotes': <String>[],
      'vocabularyNotes': <String>[],
      'score': 80,
      'encouragement': 'Bien hecho',
      'learningLanguage': 'en',
      'baseLocale': 'es',
      'promptVersion': '2026-07-23-v1',
    });

    expect(result.translation, 'Hola');
    expect(result.learningLanguage, 'en');
    expect(result.baseLocale, 'es');
    expect(result.promptVersion, '2026-07-23-v1');
    expect(result.toJson()['translation'], 'Hola');
    expect(result.toJson().containsKey('japaneseTranslation'), isFalse);
  });

  test('reads legacy japaneseTranslation data', () {
    final result = AiCorrectionResult.fromJson({
      'japaneseTranslation': '従来の翻訳',
    });

    expect(result.translation, '従来の翻訳');
  });

  test('reads database metadata keys', () {
    final result = AiCorrectionResult.fromJson({
      'learning_language': 'fr',
      'base_locale': 'en',
      'prompt_version': 'legacy-v1',
    });

    expect(result.learningLanguage, 'fr');
    expect(result.baseLocale, 'en');
    expect(result.promptVersion, 'legacy-v1');
  });

  test('matches only the same correction context', () {
    const result = AiCorrectionResult(
      transcript: '',
      correctedText: '',
      naturalExpression: '',
      translation: '',
      grammarNotes: [],
      vocabularyNotes: [],
      score: 0,
      encouragement: '',
      learningLanguage: 'en',
      baseLocale: 'es',
      promptVersion: AiCorrectionResult.currentPromptVersion,
    );

    expect(
      result.matchesContext(learningLanguage: 'en', baseLocale: 'es'),
      isTrue,
    );
    expect(
      result.matchesContext(learningLanguage: 'fr', baseLocale: 'es'),
      isFalse,
    );
    expect(
      result.matchesContext(learningLanguage: 'en', baseLocale: 'ja'),
      isFalse,
    );
    expect(
      result.matchesContext(
        learningLanguage: 'en',
        baseLocale: 'es',
        promptVersion: 'legacy-v1',
      ),
      isFalse,
    );
  });

  test('does not reuse legacy results without language metadata', () {
    const result = AiCorrectionResult(
      transcript: '',
      correctedText: '',
      naturalExpression: '',
      translation: '',
      grammarNotes: [],
      vocabularyNotes: [],
      score: 0,
      encouragement: '',
    );

    expect(
      result.matchesContext(learningLanguage: 'en', baseLocale: 'es'),
      isFalse,
    );
  });
}
