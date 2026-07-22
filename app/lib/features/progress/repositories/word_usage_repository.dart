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
      final rows = await _fetchRows(
        client: client,
        userId: userId,
        language: language,
        limit: limit,
        includeLocalizedAdvice: true,
      );

      return rows
          .map(
            (row) => WordUsage.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .where((usage) => usage.word.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      try {
        final rows = await _fetchRows(
          client: client,
          userId: userId,
          language: language,
          limit: limit,
          includeLocalizedAdvice: false,
        );
        return rows
            .map(
              (row) =>
                  WordUsage.fromJson(Map<String, dynamic>.from(row as Map)),
            )
            .where((usage) => usage.word.isNotEmpty)
            .toList(growable: false);
      } catch (_) {
        return const [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRows({
    required SupabaseClient client,
    required String userId,
    required String? language,
    required int limit,
    required bool includeLocalizedAdvice,
  }) async {
    final columns = includeLocalizedAdvice
        ? 'word, count, language, alternative_words, advice, advice_i18n'
        : 'word, count, language, alternative_words, advice';
    var query = client.from('word_usage').select(columns).eq('user_id', userId);
    if (language != null) {
      query = query.eq('language', language);
    }
    final rows = await query.order('count', ascending: false).limit(limit);
    return rows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }
}
