import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/correction/correction_result_page.dart';
import 'package:talklog/features/correction/models/ai_correction_result.dart';
import 'package:talklog/features/correction/repositories/correction_repository.dart';
import 'package:talklog/features/correction/services/edge_function_correction_service.dart';
import 'package:talklog/features/recording/models/record_entry.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes the AI correction loading error in three languages', (
    tester,
  ) async {
    final entry = RecordEntry(
      id: 'correction-localization',
      createdAt: DateTime.utc(2026, 7, 22),
      duration: const Duration(seconds: 30),
      audioPath: 'missing.m4a',
      language: 'es',
    );

    await _pump(tester, const Locale('en'), entry);
    expect(find.text('AI correction'), findsOneWidget);
    expect(find.text("Couldn't load the AI correction"), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await _pump(tester, const Locale('es'), entry);
    expect(find.text('Corrección de IA'), findsOneWidget);
    expect(find.text('No se pudo cargar la corrección de IA'), findsOneWidget);
    expect(find.text('Cerrar'), findsOneWidget);

    await _pump(tester, const Locale('ja'), entry);
    expect(find.text('AI添削'), findsOneWidget);
    expect(find.text('AI添削を読み込めませんでした'), findsOneWidget);
    expect(find.text('閉じる'), findsOneWidget);
  });

  testWidgets('does not reuse a correction from another locale', (
    tester,
  ) async {
    final entry = RecordEntry(
      id: 'mismatched-correction',
      createdAt: DateTime.utc(2026, 7, 23),
      duration: const Duration(seconds: 20),
      audioPath: 'recording.m4a',
      language: 'en',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CorrectionResultPage(
          entry: entry,
          correctionRepository: _MismatchedCorrectionRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('A correction in another language is saved'),
      findsOneWidget,
    );
    expect(find.text('Correct in the current language'), findsOneWidget);
    expect(find.text('Transcript'), findsNothing);
  });

  for (final testCase in const [
    (
      Locale('en'),
      'English grammar explanation',
      'English vocabulary explanation',
      'English translation',
      'English encouragement',
    ),
    (
      Locale('es'),
      'Explicación gramatical en español',
      'Explicación de vocabulario en español',
      'Traducción en español',
      'Mensaje de ánimo en español',
    ),
    (Locale('ja'), '日本語の文法解説', '日本語の語彙解説', '日本語の翻訳', '日本語の励まし'),
  ]) {
    testWidgets('shows all explanations in ${testCase.$1.languageCode}', (
      tester,
    ) async {
      final entry = RecordEntry(
        id: 'localized-result-${testCase.$1.languageCode}',
        createdAt: DateTime.utc(2026, 7, 23),
        duration: const Duration(seconds: 30),
        audioPath: 'recording.m4a',
        language: 'fr',
      );
      final result = AiCorrectionResult(
        transcript: 'Texte original',
        correctedText: 'Texte corrigé',
        naturalExpression: 'Expression naturelle',
        translation: testCase.$4,
        grammarNotes: [testCase.$2],
        vocabularyNotes: [testCase.$3],
        score: 90,
        encouragement: testCase.$5,
        learningLanguage: 'fr',
        baseLocale: testCase.$1.languageCode,
        promptVersion: AiCorrectionResult.currentPromptVersion,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: testCase.$1,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: CorrectionResultPage(
            entry: entry,
            correctionRepository: _SavedCorrectionRepository(result),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final text in [testCase.$2, testCase.$3, testCase.$4, testCase.$5]) {
        await tester.scrollUntilVisible(
          find.text(text),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(text), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shows progress while reanalyzing a mismatched correction', (
    tester,
  ) async {
    final entry = RecordEntry(
      id: 'reanalyze-progress',
      createdAt: DateTime.utc(2026, 7, 23),
      duration: const Duration(seconds: 10),
      audioPath: 'recording.m4a',
      language: 'es',
    );
    final service = _PendingCorrectionService();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CorrectionResultPage(
          entry: entry,
          correctionRepository: _MismatchedCorrectionRepository(),
          correctionService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Correct in the current language'));
    await tester.pump();

    expect(find.text('Analyzing your recording...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    service.complete();
    await tester.pumpAndSettle();
    expect(find.text('Corrected after waiting'), findsOneWidget);
  });
}

class _MismatchedCorrectionRepository extends CorrectionRepository {
  @override
  Future<AiCorrectionResult?> fetchSavedResult(RecordEntry entry) async => null;

  @override
  Future<bool> hasSavedResult(RecordEntry entry) async => true;
}

class _SavedCorrectionRepository extends CorrectionRepository {
  _SavedCorrectionRepository(this.result);

  final AiCorrectionResult result;

  @override
  Future<AiCorrectionResult?> fetchSavedResult(RecordEntry entry) async =>
      result;

  @override
  Future<bool> hasSavedResult(RecordEntry entry) async => true;
}

class _PendingCorrectionService extends EdgeFunctionCorrectionService {
  final _completer = Completer<AiCorrectionResult>();

  @override
  Future<AiCorrectionResult> analyze(RecordEntry entry) => _completer.future;

  void complete() {
    _completer.complete(
      const AiCorrectionResult(
        transcript: 'Original',
        correctedText: 'Corrected after waiting',
        naturalExpression: 'Natural',
        translation: 'Translation',
        grammarNotes: [],
        vocabularyNotes: [],
        score: 90,
        encouragement: 'Great',
        learningLanguage: 'es',
        baseLocale: 'en',
        promptVersion: AiCorrectionResult.currentPromptVersion,
      ),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Locale locale,
  RecordEntry entry,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: CorrectionResultPage(entry: entry),
    ),
  );
  await tester.pumpAndSettle();
}
