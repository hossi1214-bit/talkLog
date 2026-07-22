import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';
import 'package:talklog/features/settings/settings_page.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('prevents selecting the app language as practice language', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'base_locale': 'en',
      'learning_language': 'ja',
    });
    final settings = AppSettingsStore.instance;
    await settings.load();
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('en');
    await settings.setLearningLanguage('ja');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const SettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App language'), findsOneWidget);
    expect(find.text('Current: English'), findsOneWidget);
    expect(find.text('Practice language'), findsOneWidget);
    expect(find.text('Current: Japanese'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Sign in with email'), findsOneWidget);

    await tester.tap(find.text('Practice language'));
    await tester.pumpAndSettle();
    expect(find.text('Select practice language'), findsOneWidget);
    expect(find.text('English'), findsNothing);
    expect(find.text('Spanish'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japanese'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a new practice language'), findsOneWidget);
    expect(
      find.text(
        'That language is currently your practice language. Choose a different '
        'practice language before changing the app language.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(settings.baseLocaleCode, 'en');
    expect(settings.learningLanguageCode, 'ja');

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japanese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish'));
    await tester.pumpAndSettle();
    expect(settings.baseLocaleCode, 'ja');
    expect(settings.learningLanguageCode, 'es');
  });
}
