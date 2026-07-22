import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/app/app.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';

void main() {
  testWidgets('switches the app language without restarting', (tester) async {
    SharedPreferences.setMockInitialValues({
      'base_locale': 'en',
      'learning_language': 'es',
    });

    await tester.pumpWidget(const TalkLogApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('en'),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Record'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Vocabulary'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('Record'));
    await tester.pump();

    expect(
      find.text('Please sign in with your email to use this feature.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.mic), findsNothing);

    final settings = AppSettingsStore.instance;
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('es');
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('es'),
    );
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Grabar'), findsOneWidget);
    expect(find.text('Ajustes'), findsWidgets);

    await settings.setBaseLocale('ja');
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('ja'),
    );
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('録音'), findsOneWidget);
    expect(find.text('設定'), findsWidgets);
  });
}
