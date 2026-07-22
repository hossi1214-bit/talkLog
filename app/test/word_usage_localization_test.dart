import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/progress/models/word_usage.dart';

void main() {
  test('uses advice matching the current app language', () {
    final usage = WordUsage.fromJson({
      'word': 'hola',
      'count': 3,
      'language': 'es',
      'advice': '日本語の旧解説',
      'advice_i18n': {
        'ja': '日本語の解説',
        'en': 'English advice',
        'es': 'Consejo en español',
      },
    });

    expect(usage.localizedAdvice('ja', 'fallback'), '日本語の解説');
    expect(usage.localizedAdvice('en', 'fallback'), 'English advice');
    expect(usage.localizedAdvice('es', 'fallback'), 'Consejo en español');
  });

  test('does not show legacy Japanese advice in another app language', () {
    final usage = WordUsage.fromJson({
      'word': 'hola',
      'count': 3,
      'language': 'es',
      'advice': '日本語の旧解説',
    });

    expect(usage.localizedAdvice('ja', '日本語フォールバック'), '日本語の旧解説');
    expect(usage.localizedAdvice('en', 'English fallback'), 'English fallback');
    expect(
      usage.localizedAdvice('es', 'Consejo alternativo'),
      'Consejo alternativo',
    );
  });
}
