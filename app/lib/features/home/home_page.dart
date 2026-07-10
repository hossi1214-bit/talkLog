import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/services/auth_session_service.dart';
import '../progress/models/learning_stats.dart';
import '../recording/data/recording_store.dart';
import '../settings/data/app_settings_store.dart';

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

  int _audioStorageBytes = 0;
  int _storageGeneration = 0;

  @override
  void initState() {
    super.initState();
    _recordingStore.addListener(_handleStateChanged);
    _settingsStore.addListener(_handleStateChanged);
    _authSessionService.addListener(_handleStateChanged);
    unawaited(_recordingStore.load().then((_) => _refreshAudioStorageBytes()));
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
      unawaited(_refreshAudioStorageBytes());
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = _settingsStore.learningLanguage;
    final languageEntries = _recordingStore.entries
        .where((entry) => entry.language == language)
        .toList(growable: false);
    final stats = LearningStats.fromEntries(
      languageEntries,
      language: language,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('TalkLog')),
      body: !_recordingStore.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '今日も少し話してみましょう。',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '現在の学習言語: $language',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _TodayActionCard(
                  stats: stats,
                  onStartRecording: widget.onStartRecording,
                ),
                const SizedBox(height: 12),
                _AudioStorageCard(
                  usedBytes: _audioStorageBytes,
                  hasUnlimitedStorage: _authSessionService.canUsePremiumFeature,
                ),
                const SizedBox(height: 12),
                _LearningPaceCard(stats: stats),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.local_fire_department_outlined,
                  title: '現在のストリーク',
                  value: '${stats.currentStreak}日',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.mic_none,
                  title: '今日の録音',
                  value: '${stats.todayRecordings}件',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.timer_outlined,
                  title: '累計録音時間',
                  value: _formatDuration(stats.totalDuration),
                ),
                const SizedBox(height: 12),
                const _InfoCard(
                  icon: Icons.assignment_outlined,
                  title: '今日の小さなお題',
                  value: '今日よかったことを1つ、学習中の言語で話してみましょう。',
                ),
              ],
            ),
    );
  }

  Future<void> _refreshAudioStorageBytes() async {
    final generation = ++_storageGeneration;
    var totalBytes = 0;
    for (final entry in _recordingStore.entries) {
      final file = File(entry.audioPath);
      if (await file.exists()) {
        totalBytes += await file.length();
      }
    }
    if (mounted && generation == _storageGeneration) {
      setState(() {
        _audioStorageBytes = totalBytes;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) {
      return '$minutes分';
    }
    return '$hours時間$minutes分';
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
                Text('音声ストレージ', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: hasUnlimitedStorage ? null : usageRatio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasUnlimitedStorage
                  ? '${_formatBytes(usedBytes)} 使用中 / Premium容量'
                  : '${_formatBytes(usedBytes)} / ${_formatBytes(_freeLimitBytes)} 使用中',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasUnlimitedStorage
                  ? 'Premium権限のため、容量を気にせず保存できます。'
                  : isLow
                  ? '残り${_formatBytes(remainingBytes)}です。Premiumなら容量を気にせず保存できます。'
                  : '残り${_formatBytes(remainingBytes)}です。録音を続けるほど音声ログが積み上がります。',
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
    final theme = Theme.of(context);
    final message = _messageFor(stats);
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
                  Text('今日の一歩', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: onStartRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('録音を始める'),
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

  String _messageFor(LearningStats stats) {
    if (stats.todayRecordings == 0 && stats.currentStreak == 0) {
      return 'まずは30秒だけ録音して、今日の学習記録を作りましょう。';
    }
    if (stats.todayRecordings == 0) {
      return '連続記録を続けるチャンスです。短い録音を1本だけ足しましょう。';
    }
    if (stats.todayRecordings == 1) {
      return '今日の録音は完了しています。余裕があれば、理由や感想を足してもう1本話してみましょう。';
    }
    return '今日はすでに${stats.todayRecordings}本録音できています。よいペースです。';
  }
}

class _LearningPaceCard extends StatelessWidget {
  const _LearningPaceCard({required this.stats});

  final LearningStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = stats.weeklyRecordingDelta;
    final deltaText = delta > 0
        ? '+$delta回'
        : delta == 0
        ? '±0回'
        : '$delta回';
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
                Text('今週のペース', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PaceValue(
                    label: '今週',
                    value: '${stats.thisWeekRecordings}回',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PaceValue(
                    label: '先週比',
                    value: deltaText,
                    valueColor: deltaColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(stats.trendMessage, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
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
