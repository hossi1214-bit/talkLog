import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/word_usage.dart';

class WordUsageRepository {
  WordUsageRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  Future<List<WordUsage>> fetchTopWords({
    String? language,
    int limit = 10,
  }) async {
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      return const [];
    }

    try {
      final rows = language == null
          ? await client
                .from('word_usage')
                .select('word, count, language, alternative_words, advice')
                .eq('user_id', userId)
                .order('count', ascending: false)
                .limit(limit)
          : await client
                .from('word_usage')
                .select('word, count, language, alternative_words, advice')
                .eq('user_id', userId)
                .eq('language', language)
                .order('count', ascending: false)
                .limit(limit);

      return rows
          .map(
            (row) => WordUsage.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .where((usage) => usage.word.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}
