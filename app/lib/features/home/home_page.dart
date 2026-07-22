import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/services/auth_session_service.dart';
import '../../l10n/app_localizations.dart';
import '../progress/models/learning_stats.dart';
import '../recording/data/recording_store.dart';
import '../settings/data/app_settings_store.dart';
import '../settings/models/app_language.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.onStartRecording, super.key});

  final VoidCallback? onStartRecording;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _recordingStore = RecordingStore.instance;
  final _settingsStore = AppSettingsStore.instance;
  final _authSessionService = AuthSessionService.instance;

  @override
  void initState() {
    super.initState();
    _recordingStore.addListener(_handleStateChanged);
    _settingsStore.addListener(_handleStateChanged);
    _authSessionService.addListener(_handleStateChanged);
    unawaited(
      _recordingStore.load().then(
        (_) => _recordingStore.refreshAudioStorageUsage(),
      ),
    );
    _settingsStore.load();
  }

  @override
  void dispose() {
    _recordingStore.removeListener(_handleStateChanged);
    _settingsStore.removeListener(_handleStateChanged);
    _authSessionService.removeListener(_handleStateChanged);
    super.dispose();
  }

  void _handleStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = _settingsStore.learningLanguageValue;
    final languageEntries = _recordingStore.entries
        .where((entry) => AppLanguage.parse(entry.language) == language)
        .toList(growable: false);
    final stats = LearningStats.fromEntries(
      languageEntries,
      language: language.code,
    );
    final languageName = l10n.languageName(
      language.code == 'zh-Hans' ? 'zhHans' : language.code,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('TalkLog')),
      body: !_recordingStore.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.homeGreeting,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.currentLearningLanguage(languageName),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _TodayActionCard(
                  stats: stats,
                  onStartRecording: widget.onStartRecording,
                ),
                const SizedBox(height: 12),
                _AudioStorageCard(
                  usedBytes: _recordingStore.cloudAudioStorageBytes,
                  hasUnlimitedStorage: _authSessionService.canUsePremiumFeature,
                ),
                const SizedBox(height: 12),
                _LearningPaceCard(stats: stats),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.local_fire_department_outlined,
                  title: l10n.currentStreakTitle,
                  value: l10n.streakDays(stats.currentStreak),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.mic_none,
                  title: l10n.todayRecordingsTitle,
                  value: l10n.recordingCount(stats.todayRecordings),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.timer_outlined,
                  title: l10n.totalRecordingTimeTitle,
                  value: _formatDuration(l10n, stats.totalDuration),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.assignment_outlined,
                  title: l10n.todayPromptTitle,
                  value: l10n.todayPromptBody,
                ),
              ],
            ),
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

class _AudioStorageCard extends StatelessWidget {
  const _AudioStorageCard({
    required this.usedBytes,
    required this.hasUnlimitedStorage,
  });

  static const _freeLimitBytes = 200 * 1024 * 1024;

  final int usedBytes;
  final bool hasUnlimitedStorage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remainingBytes = (_freeLimitBytes - usedBytes).clamp(
      0,
      _freeLimitBytes,
    );
    final usageRatio = hasUnlimitedStorage
        ? 0.0
        : (usedBytes / _freeLimitBytes).clamp(0.0, 1.0);
    final isLow = !hasUnlimitedStorage && remainingBytes <= 20 * 1024 * 1024;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.audioStorageTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: hasUnlimitedStorage ? 1.0 : usageRatio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasUnlimitedStorage
                  ? l10n.storagePremiumUsage(_formatBytes(usedBytes))
                  : l10n.storageFreeUsage(
                      _formatBytes(usedBytes),
                      _formatBytes(_freeLimitBytes),
                    ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasUnlimitedStorage
                  ? l10n.storagePremiumDescription
                  : isLow
                  ? l10n.storageLowDescription(_formatBytes(remainingBytes))
                  : l10n.storageRemainingDescription(
                      _formatBytes(remainingBytes),
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isLow ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    if (mb < 10) {
      return '${mb.toStringAsFixed(1)}MB';
    }
    return '${mb.round()}MB';
  }
}

class _TodayActionCard extends StatelessWidget {
  const _TodayActionCard({required this.stats, required this.onStartRecording});

  final LearningStats stats;
  final VoidCallback? onStartRecording;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final message = _messageFor(l10n, stats);
    final icon = stats.todayRecordings > 0
        ? Icons.check_circle_outline
        : Icons.radio_button_unchecked;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.todayStepTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: onStartRecording,
                      icon: const Icon(Icons.mic),
                      label: Text(l10n.startRecording),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _messageFor(AppLocalizations l10n, LearningStats stats) {
    if (stats.todayRecordings == 0 && stats.currentStreak == 0) {
      return l10n.todayStartMessage;
    }
    if (stats.todayRecordings == 0) {
      return l10n.todayKeepStreakMessage;
    }
    if (stats.todayRecordings == 1) {
      return l10n.todayOneDoneMessage;
    }
    return l10n.todayManyDoneMessage(stats.todayRecordings);
  }
}

class _LearningPaceCard extends StatelessWidget {
  const _LearningPaceCard({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final delta = stats.weeklyRecordingDelta;
    final deltaText = delta > 0
        ? '+${l10n.recordingCount(delta)}'
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
                Text(l10n.weeklyPaceTitle, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PaceValue(
                    label: l10n.thisWeekLabel,
                    value: l10n.recordingCount(stats.thisWeekRecordings),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PaceValue(
                    label: l10n.versusLastWeekLabel,
                    value: deltaText,
                    valueColor: deltaColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(_trendMessage(l10n, stats), style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _trendMessage(AppLocalizations l10n, LearningStats stats) {
    if (stats.totalRecordings == 0) {
      return l10n.trendNoRecordings;
    }
    if (stats.weeklyRecordingDelta > 0) {
      return l10n.trendImproving(stats.weeklyRecordingDelta);
    }
    if (stats.weeklyRecordingDelta == 0 && stats.thisWeekRecordings > 0) {
      return l10n.trendSteady;
    }
    if (stats.thisWeekRecordings == 0) {
      return l10n.trendNoRecordingsThisWeek;
    }
    return l10n.trendSlower;
  }
}

class _PaceValue extends StatelessWidget {
  const _PaceValue({required this.label, required this.value, this.valueColor});

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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
