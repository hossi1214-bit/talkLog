import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/history/history_detail_page.dart';
import 'package:talklog/features/history/history_page.dart';
import 'package:talklog/features/recording/data/recording_store.dart';
import 'package:talklog/features/recording/models/record_entry.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes the empty history list in three languages', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await RecordingStore.instance.clearLocal();

    await _pump(tester, const Locale('en'), const HistoryPage());
    expect(find.text('History'), findsOneWidget);
    expect(find.text('No recordings yet.'), findsOneWidget);
    expect(find.text('Corrected only'), findsOneWidget);

    await _pump(tester, const Locale('es'), const HistoryPage());
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Todavía no hay grabaciones.'), findsOneWidget);

    await _pump(tester, const Locale('ja'), const HistoryPage());
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('録音はまだありません。'), findsOneWidget);
  });

  testWidgets('localizes recording details and language names', (tester) async {
    final entry = RecordEntry(
      id: 'history-localization',
      createdAt: DateTime.utc(2026, 7, 22, 8),
      duration: const Duration(seconds: 45),
      audioPath: 'missing.m4a',
      language: 'es',
    );

    await _pump(tester, const Locale('en'), HistoryDetailPage(entry: entry));
    expect(find.text('Recording details'), findsOneWidget);
    expect(find.text('Practice language'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('View AI correction'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, Locale locale, Widget home) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}
