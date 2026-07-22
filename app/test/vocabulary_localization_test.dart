import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';
import 'package:talklog/features/vocabulary/vocabulary_page.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes the empty vocabulary page in three languages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'base_locale': 'en',
      'learning_language': 'es',
    });
    final settings = AppSettingsStore.instance;
    await settings.load();
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('en');

    await _pump(tester, const Locale('en'));
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Search by first letters'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setBaseLocale('es');
    await _pump(tester, const Locale('es'));
    expect(find.text('Vocabulario'), findsOneWidget);
    expect(find.text('Repasar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setBaseLocale('ja');
    await _pump(tester, const Locale('ja'));
    expect(find.text('単語帳'), findsOneWidget);
    expect(find.text('復習'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const VocabularyPage(),
    ),
  );
  await tester.pumpAndSettle();
}
