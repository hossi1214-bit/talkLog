import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../recording/models/record_entry.dart';
import '../models/vocabulary_item.dart';

class VocabularyRepository {
  VocabularyRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  Future<List<VocabularyItem>> fetchAll({String? language}) async {
    final client = _client;
    if (client == null) {
      return const [];
    }

    final rows = language == null
        ? await client
              .from('vocabulary')
              .select()
              .order('word', ascending: true)
        : await client
              .from('vocabulary')
              .select()
              .eq('language', language)
              .order('word', ascending: true);

    return rows
        .map((row) => VocabularyItem.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  Future<void> addFromNotes({
    required RecordEntry entry,
    required List<String> notes,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    for (final note in notes) {
      final parsed = _parseNote(note);
      if (parsed == null) {
        continue;
      }
      await client.from('vocabulary').insert({
        'recording_id': entry.id,
        'language': entry.language,
        'word': parsed.word,
        'meaning': parsed.meaning,
        'is_reviewed': false,
      });
    }
  }

  Future<void> updateItem({
    required VocabularyItem item,
    required String word,
    required String meaning,
    required String? example,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client
        .from('vocabulary')
        .update({
          'word': word.trim(),
          'meaning': meaning.trim(),
          'example': example?.trim().isEmpty ?? true ? null : example!.trim(),
        })
        .eq('id', item.id);
  }

  Future<void> deleteItem(VocabularyItem item) async {
    final client = _client;
    if (client == null) {
      return;
    }

    await client.from('vocabulary').delete().eq('id', item.id);
  }

  Future<void> setReviewed(VocabularyItem item, bool isReviewed) async {
    final client = _client;
    if (client == null) {
      return;
    }

    final values = <String, Object?>{'is_reviewed': isReviewed};
    if (isReviewed) {
      values['review_count'] = item.reviewCount + 1;
      values['last_reviewed_at'] = DateTime.now().toUtc().toIso8601String();
    }

    try {
      await client.from('vocabulary').update(values).eq('id', item.id);
    } on PostgrestException catch (error) {
      if (!_isMissingReviewColumn(error)) {
        rethrow;
      }
      await client
          .from('vocabulary')
          .update({'is_reviewed': isReviewed})
          .eq('id', item.id);
    }
  }

  bool _isMissingReviewColumn(PostgrestException error) {
    final message = error.message.toLowerCase();
    return message.contains('review_count') ||
        message.contains('last_reviewed_at') ||
        message.contains('column');
  }

  _ParsedVocabulary? _parseNote(String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final separatorIndex = trimmed.indexOf(':');
    if (separatorIndex > 0) {
      return _ParsedVocabulary(
        word: trimmed.substring(0, separatorIndex).trim(),
        meaning: trimmed.substring(separatorIndex + 1).trim(),
      );
    }

    return _ParsedVocabulary(word: trimmed, meaning: '添削メモから追加');
  }
}

class _ParsedVocabulary {
  const _ParsedVocabulary({required this.word, required this.meaning});

  final String word;
  final String meaning;
}
