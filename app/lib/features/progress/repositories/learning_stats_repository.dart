import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/learning_stats.dart';

class LearningStatsRepository {
  LearningStatsRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  bool get isAvailable => _client != null;

  Future<void> syncStats(LearningStats stats) async {
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      return;
    }

    await _ensureProfile(client, userId);

    await client.from('learning_stats').upsert({
      'user_id': userId,
      'language': stats.language,
      'total_recordings': stats.totalRecordings,
      'total_duration_seconds': stats.totalDuration.inSeconds,
      'current_streak': stats.currentStreak,
      'best_streak': stats.bestStreak,
      'average_score': stats.averageScore,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,language');

    for (final dailyStats in stats.dailyStats) {
      await client.from('daily_streaks').upsert({
        'user_id': userId,
        'language': stats.language,
        'learning_date': _dateKey(dailyStats.date),
        'recording_count': dailyStats.recordingCount,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,language,learning_date');
    }
  }

  Future<void> _ensureProfile(SupabaseClient client, String userId) async {
    final user = client.auth.currentUser;
    await client.from('profiles').upsert({
      'id': userId,
      'email': user?.email,
      'display_name': user?.email ?? '匿名ユーザー',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
