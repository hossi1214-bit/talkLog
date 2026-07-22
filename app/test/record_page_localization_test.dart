import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/recording/data/recording_store.dart';
import 'package:talklog/features/recording/record_page.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes the ready recording screen in three languages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'base_locale': 'en',
      'learning_language': 'es',
    });
    await RecordingStore.instance.clearLocal();
    final settings = AppSettingsStore.instance;
    await settings.load();
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('en');
    await settings.setLearningLanguage('es');

    await _pumpRecordPage(tester, const Locale('en'));
    expect(find.text('Ready to record'), findsOneWidget);
    expect(find.text('Plan what to say'), findsOneWidget);
    expect(find.text('Create a Spanish practice text'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('es');
    await _pumpRecordPage(tester, const Locale('es'));
    expect(find.text('Listo para grabar'), findsOneWidget);
    expect(find.text('Piensa qué decir'), findsOneWidget);
    expect(find.text('Crear un texto de práctica en francés'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setBaseLocale('ja');
    await _pumpRecordPage(tester, const Locale('ja'));
    expect(find.text('録音できます'), findsOneWidget);
    expect(find.text('何を言うか考える'), findsOneWidget);
    expect(find.text('フランス語の練習文を作る'), findsOneWidget);
  });
}

Future<void> _pumpRecordPage(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const RecordPage(),
    ),
  );
  await tester.pumpAndSettle();
}
