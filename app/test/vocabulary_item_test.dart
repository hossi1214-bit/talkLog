import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/vocabulary/models/vocabulary_item.dart';

void main() {
  test('reads vocabulary language metadata and example translation', () {
    final item = VocabularyItem.fromJson({
      'id': 'word-1',
      'recording_id': 'recording-1',
      'language': 'en',
      'learning_language': 'en',
      'base_locale': 'es',
      'word': 'coffee',
      'meaning': 'café',
      'example': 'I drink coffee.',
      'example_translation': 'Bebo café.',
      'language_metadata': {'pronunciation': 'ˈkɒfi'},
      'created_at': '2026-07-23T00:00:00Z',
    });

    expect(item.learningLanguage, 'en');
    expect(item.baseLocale, 'es');
    expect(item.exampleTranslation, 'Bebo café.');
    expect(item.languageMetadata['pronunciation'], 'ˈkɒfi');
  });

  test('normalizes a legacy learning language label', () {
    final item = VocabularyItem.fromJson({
      'id': 'word-legacy',
      'recording_id': 'recording-legacy',
      'language': 'スペイン語',
      'learning_language': 'スペイン語',
      'word': 'hola',
      'meaning': 'hello',
      'created_at': '2026-07-23T00:00:00Z',
    });

    expect(item.learningLanguage, 'es');
  });
}
