import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/progress/progress_page.dart';
import 'package:talklog/features/progress/feedback_insight_detail_page.dart';
import 'package:talklog/features/correction/repositories/correction_repository.dart';
import 'package:talklog/features/recording/data/recording_store.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes progress summary in three languages', (tester) async {
    SharedPreferences.setMockInitialValues({
      'base_locale': 'en',
      'learning_language': 'es',
    });
    await RecordingStore.instance.clearLocal();
    final settings = AppSettingsStore.instance;
    await settings.load();
    await settings.setLearningLanguage('fr');
    await settings.setBaseLocale('en');

    await _pump(tester, const Locale('en'));
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Total recordings'), findsOneWidget);
    expect(find.text('Monthly summary'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setBaseLocale('es');
    await _pump(tester, const Locale('es'));
    expect(find.text('Progreso'), findsOneWidget);
    expect(find.text('Grabaciones totales'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await settings.setBaseLocale('ja');
    await _pump(tester, const Locale('ja'));
    expect(find.text('進捗'), findsOneWidget);
    expect(find.text('総録音回数'), findsOneWidget);
  });

  testWidgets('localizes feedback insight guidance', (tester) async {
    const insight = FeedbackInsight(
      text: 'Use the past tense consistently.',
      count: 3,
      categoryLabel: '文法',
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const FeedbackInsightDetailPage(insight: insight),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detalles del punto de corrección'), findsOneWidget);
    expect(find.text('Notas de mejora'), findsOneWidget);
    expect(find.text('Prueba en la próxima grabación'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const ProgressPage(),
    ),
  );
  await tester.pumpAndSettle();
}
