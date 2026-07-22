import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../correction/repositories/correction_repository.dart';
import '../recording/data/recording_store.dart';
import '../settings/data/app_settings_store.dart';
import '../settings/models/app_language.dart';
import 'feedback_insight_detail_page.dart';
import 'models/learning_stats.dart';
import 'models/word_usage.dart';
import 'repositories/learning_stats_repository.dart';
import 'repositories/word_usage_repository.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  static const _allLanguagesLabel = 'all';

  final _recordingStore = RecordingStore.instance;
  final _settingsStore = AppSettingsStore.instance;
  final _statsRepository = LearningStatsRepository();
  final _wordUsageRepository = WordUsageRepository();
  final _correctionRepository = CorrectionRepository();

  LearningStats _stats = LearningStats.fromEntries(const []);
  Future<List<WordUsage>> _wordUsageFuture = Future.value(const []);
  Future<List<FeedbackInsight>> _feedbackInsightsFuture = Future.value(
    const [],
  );
  int _averageScore = 0;
  bool _isSyncingStats = false;
  String? _syncError;
  DateTime? _lastSyncedAt;
  String? _lastSyncedSignature;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _settingsStore.learningLanguageCode;
    _recordingStore.addListener(_handleRecordingsChanged);
    _settingsStore.addListener(_handleSettingsChanged);
    _wordUsageFuture = _fetchTopWords();
    _feedbackInsightsFuture = _fetchFeedbackInsights();
    unawaited(_loadInitialData());
  }

  @override
  void dispose() {
    _recordingStore.removeListener(_handleRecordingsChanged);
    _settingsStore.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_recordingStore.load(), _settingsStore.load()]);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLanguage = _settingsStore.learningLanguageCode;
      _wordUsageFuture = _fetchTopWords();
      _feedbackInsightsFuture = _fetchFeedbackInsights();
    });
    _refreshStats(syncToCloud: true);
    unawaited(_loadAverageScore());
  }

  void _handleRecordingsChanged() {
    _refreshStats(syncToCloud: true);
    unawaited(_loadAverageScore());
  }

  void _handleSettingsChanged() {
    if (!_settingsStore.isLoaded || _selectedLanguage == null) {
      return;
    }
    setState(() {
      _selectedLanguage = _settingsStore.learningLanguageCode;
      _wordUsageFuture = _fetchTopWords();
      _feedbackInsightsFuture = _fetchFeedbackInsights();
      _averageScore = 0;
    });
    _refreshStats(syncToCloud: true);
    unawaited(_loadAverageScore());
  }

  Future<void> _handleRefresh() async {
    _refreshStats(syncToCloud: true);
    setState(() {
      _wordUsageFuture = _fetchTopWords();
      _feedbackInsightsFuture = _fetchFeedbackInsights();
    });
    await Future.wait([_wordUsageFuture, _loadAverageScore()]);
  }

  void _selectLanguage(String? language) {
    if (_selectedLanguage == language) {
      return;
    }
    setState(() {
      _selectedLanguage = language;
      _wordUsageFuture = _fetchTopWords();
      _feedbackInsightsFuture = _fetchFeedbackInsights();
      _averageScore = 0;
      _lastSyncedSignature = null;
    });
    _refreshStats(syncToCloud: true);
    unawaited(_loadAverageScore());
  }

  Future<List<WordUsage>> _fetchTopWords() {
    return _wordUsageRepository.fetchTopWords(language: _selectedLanguage);
  }

  Future<List<FeedbackInsight>> _fetchFeedbackInsights() {
    return _correctionRepository.fetchFeedbackInsights(
      language: _selectedLanguage,
    );
  }

  Future<void> _loadAverageScore() async {
    final language = _selectedLanguage;
    try {
      final averageScore = await _correctionRepository.fetchAverageScore(
        language: language,
      );
      if (!mounted || language != _selectedLanguage) {
        return;
      }
      setState(() {
        _averageScore = averageScore;
      });
      _refreshStats(syncToCloud: true);
    } catch (_) {
      if (!mounted || language != _selectedLanguage) {
        return;
      }
      setState(() {
        _averageScore = 0;
      });
      _refreshStats(syncToCloud: true);
    }
  }

  void _refreshStats({required bool syncToCloud}) {
    final entries = _selectedLanguage == null
        ? _recordingStore.entries
        : _recordingStore.entries
              .where(
                (entry) =>
                    AppLanguage.parse(entry.language)?.code ==
                    _selectedLanguage,
              )
              .toList(growable: false);
    final stats = LearningStats.fromEntries(
      entries,
      language: _selectedLanguage ?? _allLanguagesLabel,
      averageScore: _averageScore,
    );
    final shouldSync =
        syncToCloud && stats.syncSignature != _lastSyncedSignature;

    if (mounted) {
      setState(() {
        _stats = stats;
      });
    } else {
      _stats = stats;
    }

    if (shouldSync) {
      unawaited(_syncStats(stats));
    }
  }

  Future<void> _syncStats(LearningStats stats) async {
    if (_isSyncingStats) {
      return;
    }

    setState(() {
      _isSyncingStats = true;
      _syncError = null;
    });

    try {
      await _statsRepository.syncStats(stats);
      if (!mounted) {
        return;
      }
      setState(() {
        _lastSyncedSignature = stats.syncSignature;
        _lastSyncedAt = DateTime.now();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _syncError = _friendlyError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTitle)),
      body: !_recordingStore.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _LanguageFilter(
                    selectedLanguage: _selectedLanguage,
                    onSelected: _selectLanguage,
                  ),
                  const SizedBox(height: 12),
                  _SyncStatus(
                    isSyncing: _isSyncingStats,
                    error: _syncError,
                    syncedAt: _lastSyncedAt,
                  ),
                  const SizedBox(height: 12),
                  _SummaryGrid(stats: _stats),
                  const SizedBox(height: 12),
                  _StreakPanel(stats: _stats),
                  const SizedBox(height: 12),
                  _MonthlySummaryPanel(stats: _stats),
                  const SizedBox(height: 12),
                  _LearningTrendPanel(stats: _stats),
                  const SizedBox(height: 12),
                  _FeedbackInsightsPanel(
                    insightsFuture: _feedbackInsightsFuture,
                  ),
                  const SizedBox(height: 12),
                  _WeeklyChart(stats: _stats.weeklyStats),
                  const SizedBox(height: 12),
                  _WordRankingPanel(wordsFuture: _wordUsageFuture),
                  if (_stats.isEmpty) ...[
                    const SizedBox(height: 20),
                    const _EmptyHint(),
                  ],
                ],
              ),
            ),
    );
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 160) {
      return message;
    }
    return '${message.substring(0, 160)}...';
  }
}

class _LanguageFilter extends StatelessWidget {
  const _LanguageFilter({
    required this.selectedLanguage,
    required this.onSelected,
  });

  final String? selectedLanguage;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languages = [null, ...AppLanguage.values.map((value) => value.code)];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final language in languages)
          ChoiceChip(
            label: Text(
              language == null
                  ? l10n.all
                  : l10n.languageName(
                      language == 'zh-Hans' ? 'zhHans' : language,
                    ),
            ),
            selected: selectedLanguage == language,
            onSelected: (_) => onSelected(language),
          ),
      ],
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({
    required this.isSyncing,
    required this.error,
    required this.syncedAt,
  });

  final bool isSyncing;
  final String? error;
  final DateTime? syncedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final text = isSyncing
        ? l10n.syncingLearningData
        : error != null
        ? l10n.learningDataSyncFailed(error!)
        : syncedAt != null
        ? l10n.learningDataSynced(_formatTime(context, syncedAt!))
        : l10n.learningDataAutomatic;

    return Row(
      children: [
        Icon(
          error != null ? Icons.error_outline : Icons.cloud_done_outlined,
          color: error != null ? colorScheme.error : colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: error != null ? colorScheme.error : null,
            ),
          ),
        ),
        if (isSyncing)
          const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    return DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(dateTime.toLocal());
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _MetricItem(
        icon: Icons.mic_none,
        label: l10n.totalRecordings,
        value: l10n.recordingCount(stats.totalRecordings),
      ),
      _MetricItem(
        icon: Icons.timer_outlined,
        label: l10n.totalRecordingTime,
        value: _formatDuration(l10n, stats.totalDuration),
      ),
      _MetricItem(
        icon: Icons.today_outlined,
        label: l10n.todayRecordingsTitle,
        value: l10n.recordingCount(stats.todayRecordings),
      ),
      _MetricItem(
        icon: Icons.insights_outlined,
        label: l10n.averageScore,
        value: stats.averageScore == 0 ? '-' : '${stats.averageScore}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: isWide ? 1.25 : 1.55,
          ),
          itemBuilder: (context, index) => _MetricCard(item: items[index]),
        );
      },
    );
  }

  String _formatDuration(AppLocalizations l10n, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) {
      return l10n.durationMinutes(minutes);
    }
    return l10n.durationHoursMinutes(hours, minutes);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(item.icon, color: theme.colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _StreakPanel extends StatelessWidget {
  const _StreakPanel({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.streakTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.currentAndBestStreak(
                      l10n.streakDays(stats.currentStreak),
                      l10n.streakDays(stats.bestStreak),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlySummaryPanel extends StatelessWidget {
  const _MonthlySummaryPanel({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = [
      _MetricItem(
        icon: Icons.calendar_month_outlined,
        label: l10n.monthlyRecordings,
        value: l10n.recordingCount(stats.thisMonthRecordings),
      ),
      _MetricItem(
        icon: Icons.schedule_outlined,
        label: l10n.monthlyTime,
        value: _formatDuration(l10n, stats.thisMonthDuration),
      ),
      _MetricItem(
        icon: Icons.event_available_outlined,
        label: l10n.practiceDays,
        value: l10n.streakDays(stats.activeDaysThisMonth),
      ),
      _MetricItem(
        icon: Icons.av_timer_outlined,
        label: l10n.averageRecordingTime,
        value: _formatDuration(l10n, stats.averageRecordingDuration),
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.monthlySummary, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isWide ? 1.45 : 1.75,
                  ),
                  itemBuilder: (context, index) =>
                      _CompactMetricTile(item: items[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(AppLocalizations l10n, Duration duration) {
    if (duration.inSeconds == 0) {
      return l10n.durationMinutes(0);
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) {
      return l10n.durationMinutes(minutes);
    }
    return l10n.durationHoursMinutes(hours, minutes);
  }
}

class _CompactMetricTile extends StatelessWidget {
  const _CompactMetricTile({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(item.icon, color: theme.colorScheme.primary, size: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningTrendPanel extends StatelessWidget {
  const _LearningTrendPanel({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final delta = stats.weeklyRecordingDelta;
    final deltaText = delta > 0
        ? '+${l10n.recordingCount(delta)}'
        : delta == 0
        ? l10n.recordingDelta(0)
        : l10n.recordingDelta(delta);
    final deltaColor = delta >= 0
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.learningTrend, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TrendValue(
                    label: l10n.thisWeekRecordings,
                    value: l10n.recordingCount(stats.thisWeekRecordings),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TrendValue(
                    label: l10n.differenceFromLastWeek,
                    value: deltaText,
                    valueColor: deltaColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _TrendValue(
                    label: l10n.thisWeekTime,
                    value: _formatDuration(l10n, stats.thisWeekDuration),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TrendValue(
                    label: l10n.mostActiveDay,
                    value: stats.mostActiveWeekday == null
                        ? '-'
                        : _weekdayName(context, stats.mostActiveWeekday!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_trendMessage(l10n), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDuration(AppLocalizations l10n, Duration duration) {
    if (duration.inSeconds == 0) {
      return l10n.durationMinutes(0);
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) {
      return l10n.durationMinutes(minutes);
    }
    return l10n.durationHoursMinutes(hours, minutes);
  }

  String _weekdayName(BuildContext context, int weekday) {
    final monday = DateTime(2024, 1, 1);
    return DateFormat.EEEE(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(monday.add(Duration(days: weekday - DateTime.monday)));
  }

  String _trendMessage(AppLocalizations l10n) {
    if (stats.totalRecordings == 0) return l10n.trendNoRecordings;
    if (stats.weeklyRecordingDelta > 0) {
      return l10n.trendImproving(stats.weeklyRecordingDelta);
    }
    if (stats.weeklyRecordingDelta == 0 && stats.thisWeekRecordings > 0) {
      return l10n.trendSteady;
    }
    if (stats.thisWeekRecordings == 0) return l10n.trendNoRecordingsThisWeek;
    return l10n.trendSlower;
  }
}

class _TrendValue extends StatelessWidget {
  const _TrendValue({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackInsightsPanel extends StatelessWidget {
  const _FeedbackInsightsPanel({required this.insightsFuture});

  final Future<List<FeedbackInsight>> insightsFuture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_alt_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.frequentCorrectionPoints,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<FeedbackInsight>>(
              future: insightsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    l10n.correctionPointsLoadFailed('${snapshot.error}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  );
                }

                final insights = snapshot.data ?? const [];
                if (insights.isEmpty) {
                  return Text(
                    l10n.correctionPointsEmpty,
                    style: theme.textTheme.bodyMedium,
                  );
                }

                return Column(
                  children: [
                    for (final insight in insights)
                      _FeedbackInsightTile(insight: insight),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackInsightTile extends StatelessWidget {
  const _FeedbackInsightTile({required this.insight});

  final FeedbackInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FeedbackInsightDetailPage(insight: insight),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(insight.categoryLabel),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(insight.text, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).recordingCount(insight.count),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.stats});

  final List<DailyLearningStats> stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final maxCount = stats.fold<int>(
      1,
      (max, dailyStats) =>
          dailyStats.recordingCount > max ? dailyStats.recordingCount : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.lastSevenDays, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final dailyStats in stats)
                    Expanded(
                      child: _DailyBar(stats: dailyStats, maxCount: maxCount),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBar extends StatelessWidget {
  const _DailyBar({required this.stats, required this.maxCount});

  final DailyLearningStats stats;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratio = stats.recordingCount == 0
        ? 0.04
        : stats.recordingCount / maxCount;
    final label = DateFormat.Md(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(stats.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${stats.recordingCount}', style: theme.textTheme.labelSmall),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: ratio.clamp(0.04, 1.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: stats.recordingCount == 0
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const SizedBox(width: double.infinity),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(child: Text(label, style: theme.textTheme.labelSmall)),
        ],
      ),
    );
  }
}

class _WordRankingPanel extends StatelessWidget {
  const _WordRankingPanel({required this.wordsFuture});

  final Future<List<WordUsage>> wordsFuture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(l10n.topWords, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<WordUsage>>(
              future: wordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    l10n.wordRankingLoadFailed('${snapshot.error}'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  );
                }

                final words = snapshot.data ?? const [];
                if (words.isEmpty) {
                  return Text(
                    l10n.wordRankingEmpty,
                    style: theme.textTheme.bodyMedium,
                  );
                }

                return Column(
                  children: [
                    for (var index = 0; index < words.length; index++)
                      _WordUsageTile(rank: index + 1, usage: words[index]),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WordUsageTile extends StatelessWidget {
  const _WordUsageTile({required this.rank, required this.usage});

  final int rank;
  final WordUsage usage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localizedAdvice = usage.localizedAdvice(
      AppSettingsStore.instance.baseLocaleCode,
      l10n.wordUsageAdviceFallback(usage.word),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  usage.word,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.recordingCount(usage.count),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (usage.alternativeWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final alternative in usage.alternativeWords)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(alternative),
                  ),
              ],
            ),
          ],
          if (localizedAdvice.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(localizedAdvice, style: theme.textTheme.bodyMedium),
          ],
          const Divider(height: 22),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        AppLocalizations.of(context).progressEmpty,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
