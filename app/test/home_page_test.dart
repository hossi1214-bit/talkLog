import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/home/home_page.dart';
import 'package:talklog/features/recording/data/recording_store.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes the home page in English, Spanish, and Japanese', (
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

    await _pumpHome(tester, const Locale('en'));
    expect(find.text("Let's speak a little today!"), findsOneWidget);
    expect(find.text('Practice language: Spanish'), findsOneWidget);
    expect(find.text("Today's step"), findsOneWidget);
    expect(find.text('0 recordings'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('es');
    await _pumpHome(tester, const Locale('es'));
    expect(find.text('¡Hablemos un poco hoy!'), findsOneWidget);
    expect(find.text('Idioma de práctica: francés'), findsOneWidget);
    expect(find.text('El paso de hoy'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setBaseLocale('ja');
    await _pumpHome(tester, const Locale('ja'));
    expect(find.text('今日も少し話してみましょう！'), findsOneWidget);
    expect(find.text('現在の学習言語: フランス語'), findsOneWidget);
    expect(find.text('今日の一歩'), findsOneWidget);
  });
}

Future<void> _pumpHome(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HomePage(),
    ),
  );
  await tester.pumpAndSettle();
}
