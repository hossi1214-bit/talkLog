import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../recording/models/record_entry.dart';
import '../../settings/data/app_settings_store.dart';
import '../../settings/models/app_language.dart';
import '../models/ai_correction_result.dart';

class FeedbackInsight {
  const FeedbackInsight({
    required this.text,
    required this.count,
    required this.categoryLabel,
  });

  final String text;
  final int count;
  final String categoryLabel;

  String get shortAdvice {
    if (categoryLabel == '文法') {
      return '同じ指摘が出やすい文法です。次の録音では、このポイントを1つだけ意識して話してみましょう。';
    }
    return '表現の幅を広げやすい語彙ポイントです。似た場面で別の言い方も試してみましょう。';
  }

  String get practicePrompt {
    if (categoryLabel == '文法') {
      return '今日の出来事を2文で話し、この文法ポイントを意識して言い直してみましょう。';
    }
    return 'この語彙ポイントを使って、最近あったことを1文で説明してみましょう。';
  }
}

class CorrectionRepository {
  CorrectionRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  bool get isAvailable => _client != null;

  Future<AiCorrectionResult?> fetchSavedResult(RecordEntry entry) async {
    final client = _client;
    if (client == null) {
      return null;
    }

    final transcriptRow = await client
        .from('transcripts')
        .select('original_text')
        .eq('recording_id', entry.id)
        .maybeSingle();
    final baseLocale = AppSettingsStore.instance.baseLocaleCode;
    final feedbackRow = await client
        .from('feedbacks')
        .select(
          'corrected_text, natural_expression, translation_ja, grammar_feedback, vocabulary_feedback, score, comment, learning_language, base_locale, prompt_version',
        )
        .eq('recording_id', entry.id)
        .inFilter('learning_language', storedLanguageValues(entry.languageCode))
        .eq('base_locale', baseLocale)
        .eq('prompt_version', AiCorrectionResult.currentPromptVersion)
        .maybeSingle();

    if (transcriptRow == null || feedbackRow == null) {
      return null;
    }

    return AiCorrectionResult(
      transcript: transcriptRow['original_text'] as String? ?? '',
      correctedText: feedbackRow['corrected_text'] as String? ?? '',
      naturalExpression: feedbackRow['natural_expression'] as String? ?? '',
      translation: feedbackRow['translation_ja'] as String? ?? '',
      grammarNotes: _stringList(feedbackRow['grammar_feedback']),
      vocabularyNotes: _stringList(feedbackRow['vocabulary_feedback']),
      score: feedbackRow['score'] as int? ?? 0,
      encouragement: feedbackRow['comment'] as String? ?? '',
      learningLanguage: feedbackRow['learning_language'] as String?,
      baseLocale: feedbackRow['base_locale'] as String?,
      promptVersion: feedbackRow['prompt_version'] as String?,
    );
  }

  Future<bool> hasSavedResult(RecordEntry entry) async {
    final client = _client;
    if (client == null) {
      return false;
    }

    final row = await client
        .from('feedbacks')
        .select('id')
        .eq('recording_id', entry.id)
        .limit(1)
        .maybeSingle();
    return row != null;
  }

  Future<Set<String>> fetchCorrectedRecordingIds() async {
    final client = _client;
    if (client == null) {
      return const {};
    }

    final rows = await client.from('feedbacks').select('recording_id');
    return rows
        .map((row) => Map<String, dynamic>.from(row)['recording_id'] as String?)
        .whereType<String>()
        .toSet();
  }

  Future<int> fetchAverageScore({String? language}) async {
    final client = _client;
    if (client == null) {
      return 0;
    }

    var query = client
        .from('feedbacks')
        .select('score, recordings!inner(language)')
        .eq('base_locale', AppSettingsStore.instance.baseLocaleCode)
        .eq('prompt_version', AiCorrectionResult.currentPromptVersion);
    if (language != null) {
      query = query.eq('recordings.language', language);
    }

    final rows = await query;
    final scores = rows
        .map((row) => Map<String, dynamic>.from(row)['score'])
        .whereType<int>()
        .where((score) => score > 0)
        .toList(growable: false);
    if (scores.isEmpty) {
      return 0;
    }

    final total = scores.fold<int>(0, (sum, score) => sum + score);
    return (total / scores.length).round();
  }

  Future<List<FeedbackInsight>> fetchFeedbackInsights({
    String? language,
    int limit = 5,
  }) async {
    final client = _client;
    if (client == null) {
      return const [];
    }

    var query = client
        .from('feedbacks')
        .select(
          'grammar_feedback, vocabulary_feedback, recordings!inner(language)',
        )
        .eq('base_locale', AppSettingsStore.instance.baseLocaleCode)
        .eq('prompt_version', AiCorrectionResult.currentPromptVersion);
    if (language != null) {
      query = query.eq('recordings.language', language);
    }

    final rows = await query;
    final counts = <String, _InsightCounter>{};

    for (final row in rows) {
      final data = Map<String, dynamic>.from(row);
      _countNotes(
        counts: counts,
        notes: _stringList(data['grammar_feedback']),
        categoryLabel: '文法',
      );
      _countNotes(
        counts: counts,
        notes: _stringList(data['vocabulary_feedback']),
        categoryLabel: '語彙',
      );
    }

    final insights = counts.values.toList()
      ..sort((a, b) {
        final countCompare = b.count.compareTo(a.count);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.text.compareTo(b.text);
      });

    return insights
        .take(limit)
        .map(
          (insight) => FeedbackInsight(
            text: insight.text,
            count: insight.count,
            categoryLabel: insight.categoryLabel,
          ),
        )
        .toList(growable: false);
  }

  void _countNotes({
    required Map<String, _InsightCounter> counts,
    required List<String> notes,
    required String categoryLabel,
  }) {
    for (final note in notes) {
      final normalized = _normalizeInsightText(note);
      if (normalized.isEmpty) {
        continue;
      }
      final key = '$categoryLabel:$normalized';
      final current = counts[key];
      counts[key] = _InsightCounter(
        text: normalized,
        count: (current?.count ?? 0) + 1,
        categoryLabel: categoryLabel,
      );
    }
  }

  String _normalizeInsightText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<void> saveResult({
    required RecordEntry entry,
    required AiCorrectionResult result,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client.from('transcripts').upsert({
      'recording_id': entry.id,
      'original_text': result.transcript,
      'language': entry.language,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'recording_id');

    await client.from('feedbacks').upsert({
      'recording_id': entry.id,
      'corrected_text': result.correctedText,
      'natural_expression': result.naturalExpression,
      'translation_ja': result.translation,
      'grammar_feedback': result.grammarNotes,
      'vocabulary_feedback': result.vocabularyNotes,
      'score': result.score,
      'comment': result.encouragement,
      'learning_language': result.learningLanguage ?? entry.languageCode,
      'base_locale':
          result.baseLocale ?? AppSettingsStore.instance.baseLocaleCode,
      'prompt_version':
          result.promptVersion ?? AiCorrectionResult.currentPromptVersion,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'recording_id,learning_language,base_locale,prompt_version');
  }

  Future<void> saveDummyResult({
    required RecordEntry entry,
    required AiCorrectionResult result,
  }) {
    return saveResult(entry: entry, result: result);
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}

class _InsightCounter {
  const _InsightCounter({
    required this.text,
    required this.count,
    required this.categoryLabel,
  });

  final String text;
  final int count;
  final String categoryLabel;

  String get shortAdvice {
    if (categoryLabel == '文法') {
      return '同じ指摘が出やすい文法です。次の録音では、このポイントを1つだけ意識して話してみましょう。';
    }
    return '表現の幅を広げやすい語彙ポイントです。似た場面で別の言い方も試してみましょう。';
  }

  String get practicePrompt {
    if (categoryLabel == '文法') {
      return '今日の出来事を2文で話し、この文法ポイントを意識して言い直してみましょう。';
    }
    return 'この語彙ポイントを使って、最近あったことを1文で説明してみましょう。';
  }
}
