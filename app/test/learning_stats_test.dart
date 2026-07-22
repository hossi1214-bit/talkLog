import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/progress/models/learning_stats.dart';
import 'package:talklog/features/recording/models/record_entry.dart';

void main() {
  test('calculates totals, today count, streaks, and weekly stats', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final yesterday = today.subtract(const Duration(days: 1));
    final threeDaysAgo = today.subtract(const Duration(days: 3));
    final previousWeek = today.subtract(const Duration(days: 8));

    final stats = LearningStats.fromEntries([
      RecordEntry(
        id: 'today-1',
        createdAt: today,
        duration: const Duration(seconds: 30),
        audioPath: 'today-1.m4a',
      ),
      RecordEntry(
        id: 'today-2',
        createdAt: today.add(const Duration(hours: 1)),
        duration: const Duration(seconds: 40),
        audioPath: 'today-2.m4a',
      ),
      RecordEntry(
        id: 'yesterday-1',
        createdAt: yesterday,
        duration: const Duration(seconds: 50),
        audioPath: 'yesterday-1.m4a',
      ),
      RecordEntry(
        id: 'three-days-ago-1',
        createdAt: threeDaysAgo,
        duration: const Duration(seconds: 60),
        audioPath: 'three-days-ago-1.m4a',
      ),
      RecordEntry(
        id: 'previous-week-1',
        createdAt: previousWeek,
        duration: const Duration(seconds: 70),
        audioPath: 'previous-week-1.m4a',
      ),
    ]);

    expect(stats.totalRecordings, 5);
    expect(stats.totalDuration, const Duration(seconds: 250));
    expect(stats.todayRecordings, 2);
    expect(stats.currentStreak, 2);
    expect(stats.bestStreak, 2);
    expect(stats.weeklyStats.length, 7);
    expect(stats.weeklyStats.last.recordingCount, 2);
    expect(stats.thisWeekRecordings, 4);
    expect(stats.thisWeekDuration, const Duration(seconds: 180));
    expect(stats.previousWeekRecordings, 1);
    expect(stats.previousWeekDuration, const Duration(seconds: 70));
    expect(stats.weeklyRecordingDelta, 3);
    expect(stats.thisMonthRecordings, greaterThanOrEqualTo(4));
    expect(stats.averageRecordingDuration, const Duration(seconds: 50));
    expect(stats.mostActiveWeekdayRecordings, greaterThanOrEqualTo(2));
    final expectedMostActiveWeekday = today.weekday < yesterday.weekday
        ? today.weekday
        : yesterday.weekday;
    expect(stats.mostActiveWeekday, expectedMostActiveWeekday);
  });
}
