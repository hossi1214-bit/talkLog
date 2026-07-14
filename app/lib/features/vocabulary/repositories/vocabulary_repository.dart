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

    final items = rows
        .map((row) => VocabularyItem.fromJson(Map<String, dynamic>.from(row)))
        .map(_normalizeStoredItem)
        .toList(growable: false);
    final restoredItems = await _restoreMeaningsFromFeedback(items);
    return _dedupeItems(restoredItems);
  }

  Future<void> addFromNotes({
    required RecordEntry entry,
    required List<String> notes,
  }) async {
    final client = _client;
    if (client == null) {
      return;
    }

    final existingItems = await fetchAll(language: entry.language);
    final existingByKey = {
      for (final item in existingItems)
        _vocabularyKey(item.language, item.word): item,
    };
    final newKeys = <String>{};

    for (final note in notes) {
      final parsed = _parseNote(note);
      if (parsed == null) {
        continue;
      }

      final key = _vocabularyKey(entry.language, parsed.word);
      final existing = existingByKey[key];
      if (existing != null) {
        if (_hasFallbackMeaning(existing) &&
            !_isFallbackMeaning(parsed.meaning)) {
          await updateItem(
            item: existing,
            word: existing.word,
            meaning: parsed.meaning,
            example: existing.example,
          );
        }
        continue;
      }
      if (newKeys.contains(key)) {
        continue;
      }
      newKeys.add(key);

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

  Future<List<VocabularyItem>> _restoreMeaningsFromFeedback(
    List<VocabularyItem> items,
  ) async {
    final client = _client;
    if (client == null || !items.any(_hasFallbackMeaning)) {
      return items;
    }

    final recordingIds = items
        .where(_hasFallbackMeaning)
        .map((item) => item.recordingId)
        .toSet()
        .toList(growable: false);
    if (recordingIds.isEmpty) {
      return items;
    }

    try {
      final rows = await client
          .from('feedbacks')
          .select('recording_id, vocabulary_feedback')
          .inFilter('recording_id', recordingIds);
      final notesByRecordingId = <String, List<String>>{};
      for (final row in rows) {
        final data = Map<String, dynamic>.from(row);
        final recordingId = data['recording_id'] as String?;
        if (recordingId == null) {
          continue;
        }
        notesByRecordingId[recordingId] = _stringList(
          data['vocabulary_feedback'],
        );
      }

      return items
          .map((item) => _restoreMeaningFromNotes(item, notesByRecordingId))
          .toList(growable: false);
    } on PostgrestException {
      return items;
    }
  }

  VocabularyItem _restoreMeaningFromNotes(
    VocabularyItem item,
    Map<String, List<String>> notesByRecordingId,
  ) {
    if (!_hasFallbackMeaning(item)) {
      return item;
    }

    final notes = notesByRecordingId[item.recordingId] ?? const <String>[];
    for (final note in notes) {
      final parsed = _parseStructuredNote(note.trim());
      if (parsed == null || _isFallbackMeaning(parsed.meaning)) {
        continue;
      }
      if (_vocabularyKey(item.language, parsed.word) !=
          _vocabularyKey(item.language, item.word)) {
        continue;
      }
      return VocabularyItem(
        id: item.id,
        recordingId: item.recordingId,
        language: item.language,
        word: item.word,
        meaning: parsed.meaning,
        example: item.example,
        isReviewed: item.isReviewed,
        reviewCount: item.reviewCount,
        lastReviewedAt: item.lastReviewedAt,
        createdAt: item.createdAt,
      );
    }

    return item;
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }

  _ParsedVocabulary? _parseNote(String note) {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final structured = _parseStructuredNote(trimmed);
    if (structured != null) {
      return structured;
    }

    return _ParsedVocabulary(
      word: _cleanHeadword(trimmed),
      meaning: '添削結果から追加',
    );
  }

  _ParsedVocabulary? _parseStructuredNote(String trimmed) {
    final separatorMatch = RegExp(
      r'^(.{1,80}?)[：:]\s*(.+)$',
    ).firstMatch(trimmed);
    if (separatorMatch != null) {
      return _ParsedVocabulary(
        word: _cleanHeadword(separatorMatch.group(1)!),
        meaning: separatorMatch.group(2)!.trim(),
      );
    }

    final hyphenMatch = RegExp(
      r'^(.{1,80}?)\s+[−–—-]\s+(.+)$',
    ).firstMatch(trimmed);
    if (hyphenMatch != null) {
      return _ParsedVocabulary(
        word: _cleanHeadword(hyphenMatch.group(1)!),
        meaning: hyphenMatch.group(2)!.trim(),
      );
    }

    final quotedJapaneseMatch = RegExp(
      r'''^[「『"“”'](.+?)[」』"“”']\s*(?:とは|は)\s*(.+)$''',
    ).firstMatch(trimmed);
    if (quotedJapaneseMatch != null) {
      return _ParsedVocabulary(
        word: _cleanHeadword(quotedJapaneseMatch.group(1)!),
        meaning: quotedJapaneseMatch.group(2)!.trim(),
      );
    }

    final japaneseMatch = RegExp(
      r'^(.{1,80}?)\s*(?:とは|は)\s*(.+)$',
    ).firstMatch(trimmed);
    if (japaneseMatch != null) {
      final word = _cleanHeadword(japaneseMatch.group(1)!);
      if (_looksLikeHeadword(word)) {
        return _ParsedVocabulary(
          word: word,
          meaning: japaneseMatch.group(2)!.trim(),
        );
      }
    }

    return null;
  }

  VocabularyItem _normalizeStoredItem(VocabularyItem item) {
    final parsed = _parseStructuredNote(item.word.trim());
    if (parsed == null) {
      return item;
    }

    final meaning = item.meaning.trim();
    return VocabularyItem(
      id: item.id,
      recordingId: item.recordingId,
      language: item.language,
      word: parsed.word,
      meaning: meaning.isEmpty || meaning == item.word
          ? parsed.meaning
          : meaning,
      example: item.example,
      isReviewed: item.isReviewed,
      reviewCount: item.reviewCount,
      lastReviewedAt: item.lastReviewedAt,
      createdAt: item.createdAt,
    );
  }

  List<VocabularyItem> _dedupeItems(Iterable<VocabularyItem> items) {
    final byKey = <String, VocabularyItem>{};
    for (final item in items) {
      final key = _vocabularyKey(item.language, item.word);
      final existing = byKey[key];
      byKey[key] = existing == null ? item : _mergeItems(existing, item);
    }

    final deduped = byKey.values.toList(growable: false);
    deduped.sort((a, b) {
      final wordCompare = a.word.toLowerCase().compareTo(b.word.toLowerCase());
      if (wordCompare != 0) {
        return wordCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return deduped;
  }

  VocabularyItem _mergeItems(VocabularyItem first, VocabularyItem second) {
    return VocabularyItem(
      id: first.id,
      recordingId: first.recordingId,
      language: first.language,
      word: first.word,
      meaning: _mergeText(first.meaning, second.meaning),
      example: _mergeNullableText(first.example, second.example),
      isReviewed: first.isReviewed && second.isReviewed,
      reviewCount: first.reviewCount + second.reviewCount,
      lastReviewedAt: _latestDate(first.lastReviewedAt, second.lastReviewedAt),
      createdAt: first.createdAt.isBefore(second.createdAt)
          ? first.createdAt
          : second.createdAt,
    );
  }

  String _mergeText(String first, String second) {
    final values = [
      first.trim(),
      second.trim(),
    ].where((value) => value.isNotEmpty).toSet().toList(growable: false);
    return values.join('\n\n');
  }

  String? _mergeNullableText(String? first, String? second) {
    final merged = _mergeText(first ?? '', second ?? '');
    return merged.isEmpty ? null : merged;
  }

  DateTime? _latestDate(DateTime? first, DateTime? second) {
    if (first == null) {
      return second;
    }
    if (second == null) {
      return first;
    }
    return first.isAfter(second) ? first : second;
  }

  String _vocabularyKey(String language, String word) {
    return '${language.trim().toLowerCase()}|${_normalizeWord(word)}';
  }

  String _normalizeWord(String value) {
    return _cleanHeadword(value).toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _hasFallbackMeaning(VocabularyItem item) {
    return _isFallbackMeaning(item.meaning);
  }

  bool _isFallbackMeaning(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ||
        normalized == '添削結果から追加' ||
        normalized == '添削メモから追加';
  }

  String _cleanHeadword(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'''^[\s「『"“”']+|[\s」』"“”'。,.、]+$'''), '')
        .trim();
  }

  bool _looksLikeHeadword(String value) {
    if (value.isEmpty || value.length > 80) {
      return false;
    }
    return RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(value) ||
        !RegExp(r'[。！？!?]').hasMatch(value);
  }
}

class _ParsedVocabulary {
  const _ParsedVocabulary({required this.word, required this.meaning});

  final String word;
  final String meaning;
}
