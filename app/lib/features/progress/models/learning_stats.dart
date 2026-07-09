import '../../recording/models/record_entry.dart';

class LearningStats {
  const LearningStats({
    required this.language,
    required this.totalRecordings,
    required this.totalDuration,
    required this.todayRecordings,
    required this.thisMonthRecordings,
    required this.thisMonthDuration,
    required this.activeDaysThisMonth,
    required this.averageRecordingDuration,
    required this.thisWeekRecordings,
    required this.thisWeekDuration,
    required this.previousWeekRecordings,
    required this.previousWeekDuration,
    required this.mostActiveWeekday,
    required this.mostActiveWeekdayRecordings,
    required this.currentStreak,
    required this.bestStreak,
    required this.averageScore,
    required this.dailyStats,
    required this.weeklyStats,
  });

  final String language;
  final int totalRecordings;
  final Duration totalDuration;
  final int todayRecordings;
  final int thisMonthRecordings;
  final Duration thisMonthDuration;
  final int activeDaysThisMonth;
  final Duration averageRecordingDuration;
  final int thisWeekRecordings;
  final Duration thisWeekDuration;
  final int previousWeekRecordings;
  final Duration previousWeekDuration;
  final String mostActiveWeekday;
  final int mostActiveWeekdayRecordings;
  final int currentStreak;
  final int bestStreak;
  final int averageScore;
  final List<DailyLearningStats> dailyStats;
  final List<DailyLearningStats> weeklyStats;

  bool get isEmpty => totalRecordings == 0;

  int get weeklyRecordingDelta => thisWeekRecordings - previousWeekRecordings;

  String get trendMessage {
    if (totalRecordings == 0) {
      return 'まずは1回録音して、学習リズムを作りましょう。';
    }
    if (weeklyRecordingDelta > 0) {
      return '先週より$weeklyRecordingDelta回多く録音できています。この調子です。';
    }
    if (weeklyRecordingDelta == 0 && thisWeekRecordings > 0) {
      return '先週と同じペースで続けられています。短くても継続できています。';
    }
    if (thisWeekRecordings == 0) {
      return '今週はまだ録音がありません。30秒だけ話すところから戻しましょう。';
    }
    return '先週より録音回数が少なめです。今日は短い録音を1本だけ足してみましょう。';
  }

  String get syncSignature {
    final dailyPart = dailyStats
        .map(
          (stats) =>
              '${_dateKey(stats.date)}:${stats.recordingCount}:${stats.duration.inSeconds}',
        )
        .join('|');
    return '$language:$totalRecordings:${totalDuration.inSeconds}:$currentStreak:$bestStreak:$averageScore:$dailyPart';
  }

  static LearningStats fromEntries(
    List<RecordEntry> entries, {
    String language = 'すべて',
    int averageScore = 0,
  }) {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final dailyMap = <DateTime, DailyLearningStats>{};
    final weekdayCounts = <int, int>{};

    for (final entry in entries) {
      final date = _dateOnly(entry.createdAt.toLocal());
      final current = dailyMap[date];
      dailyMap[date] = DailyLearningStats(
        date: date,
        recordingCount: (current?.recordingCount ?? 0) + 1,
        duration: (current?.duration ?? Duration.zero) + entry.duration,
      );
      weekdayCounts[date.weekday] = (weekdayCounts[date.weekday] ?? 0) + 1;
    }

    final dailyStats = dailyMap.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final activeDates = dailyMap.keys.toSet();
    final monthStart = DateTime(today.year, today.month);
    final thisMonthEntries = entries
        .where((entry) {
          final date = _dateOnly(entry.createdAt.toLocal());
          return !date.isBefore(monthStart) && !date.isAfter(today);
        })
        .toList(growable: false);
    final thisMonthDuration = thisMonthEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
    final activeDaysThisMonth = activeDates
        .where((date) => !date.isBefore(monthStart) && !date.isAfter(today))
        .length;

    final thisWeekStart = today.subtract(const Duration(days: 6));
    final previousWeekStart = today.subtract(const Duration(days: 13));
    final previousWeekEnd = today.subtract(const Duration(days: 7));
    final thisWeekEntries = entries
        .where((entry) {
          final date = _dateOnly(entry.createdAt.toLocal());
          return !date.isBefore(thisWeekStart) && !date.isAfter(today);
        })
        .toList(growable: false);
    final previousWeekEntries = entries
        .where((entry) {
          final date = _dateOnly(entry.createdAt.toLocal());
          return !date.isBefore(previousWeekStart) &&
              !date.isAfter(previousWeekEnd);
        })
        .toList(growable: false);
    final thisWeekDuration = thisWeekEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
    final previousWeekDuration = previousWeekEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );

    final currentStreak = _calculateCurrentStreak(activeDates, today);
    final bestStreak = _calculateBestStreak(activeDates);
    final totalDuration = entries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
    final averageRecordingDuration = entries.isEmpty
        ? Duration.zero
        : Duration(seconds: totalDuration.inSeconds ~/ entries.length);
    final weeklyStats = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      return dailyMap[date] ??
          DailyLearningStats(
            date: date,
            recordingCount: 0,
            duration: Duration.zero,
          );
    });
    final mostActiveWeekdayEntry = _mostActiveWeekdayEntry(weekdayCounts);

    return LearningStats(
      language: language,
      totalRecordings: entries.length,
      totalDuration: totalDuration,
      todayRecordings: dailyMap[today]?.recordingCount ?? 0,
      thisMonthRecordings: thisMonthEntries.length,
      thisMonthDuration: thisMonthDuration,
      activeDaysThisMonth: activeDaysThisMonth,
      averageRecordingDuration: averageRecordingDuration,
      thisWeekRecordings: thisWeekEntries.length,
      thisWeekDuration: thisWeekDuration,
      previousWeekRecordings: previousWeekEntries.length,
      previousWeekDuration: previousWeekDuration,
      mostActiveWeekday: mostActiveWeekdayEntry == null
          ? '-'
          : _weekdayLabel(mostActiveWeekdayEntry.key),
      mostActiveWeekdayRecordings: mostActiveWeekdayEntry?.value ?? 0,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      averageScore: averageScore,
      dailyStats: dailyStats,
      weeklyStats: weeklyStats,
    );
  }

  static MapEntry<int, int>? _mostActiveWeekdayEntry(Map<int, int> counts) {
    if (counts.isEmpty) {
      return null;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.key.compareTo(b.key);
      });
    return entries.first;
  }

  static String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => '月曜日',
      DateTime.tuesday => '火曜日',
      DateTime.wednesday => '水曜日',
      DateTime.thursday => '木曜日',
      DateTime.friday => '金曜日',
      DateTime.saturday => '土曜日',
      DateTime.sunday => '日曜日',
      _ => '-',
    };
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static int _calculateCurrentStreak(
    Set<DateTime> activeDates,
    DateTime today,
  ) {
    if (activeDates.isEmpty) {
      return 0;
    }

    var cursor = activeDates.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (activeDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int _calculateBestStreak(Set<DateTime> activeDates) {
    if (activeDates.isEmpty) {
      return 0;
    }

    final dates = activeDates.toList()..sort();
    var best = 1;
    var current = 1;
    for (var index = 1; index < dates.length; index++) {
      final previous = dates[index - 1];
      final date = dates[index];
      if (date.difference(previous).inDays == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > best) {
        best = current;
      }
    }
    return best;
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class DailyLearningStats {
  const DailyLearningStats({
    required this.date,
    required this.recordingCount,
    required this.duration,
  });

  final DateTime date;
  final int recordingCount;
  final Duration duration;
}
