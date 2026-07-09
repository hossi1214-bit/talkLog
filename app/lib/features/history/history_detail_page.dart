import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../correction/correction_result_page.dart';
import '../correction/repositories/correction_repository.dart';
import '../recording/data/recording_store.dart';
import '../recording/models/record_entry.dart';
import '../recording/repositories/recording_repository.dart';

class HistoryDetailPage extends StatefulWidget {
  const HistoryDetailPage({required this.entry, super.key});

  final RecordEntry entry;

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  final _player = AudioPlayer();
  final _recordingRepository = SupabaseRecordingRepository();
  final _correctionRepository = CorrectionRepository();
  bool _isPlaying = false;
  bool _isDeleting = false;
  late Future<_RecordingCloudStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatus();
    _player.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlaying = state.playing;
      });
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<_RecordingCloudStatus> _loadStatus() async {
    final isSynced = await _recordingRepository.hasRemoteRecording(
      widget.entry,
    );
    final hasCorrection = await _correctionRepository.hasSavedResult(
      widget.entry,
    );
    return _RecordingCloudStatus(
      isSynced: isSynced,
      hasCorrection: hasCorrection,
    );
  }

  void _reloadStatus() {
    setState(() {
      _statusFuture = _loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Scaffold(
      appBar: AppBar(
        title: const Text('録音の詳細'),
        actions: [
          IconButton(
            tooltip: '状態を更新',
            icon: const Icon(Icons.refresh),
            onPressed: _reloadStatus,
          ),
          IconButton(
            tooltip: '削除',
            icon: const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _confirmAndDeleteEntry,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _formatDateTime(entry.createdAt),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          FutureBuilder<_RecordingCloudStatus>(
            future: _statusFuture,
            builder: (context, snapshot) {
              return _StatusPanel(status: snapshot.data);
            },
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.timer_outlined,
            label: '録音時間',
            value: _formatDuration(entry.duration),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.translate,
            label: '学習言語',
            value: entry.language,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.folder_outlined,
            label: '音声ファイル',
            value: entry.audioPath,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI添削を見る'),
            onPressed: _openCorrectionResult,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying ? '一時停止' : '再生'),
            onPressed: _togglePlayback,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('録音を削除'),
            onPressed: _isDeleting ? null : _confirmAndDeleteEntry,
          ),
        ],
      ),
    );
  }

  void _openCorrectionResult() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CorrectionResultPage(entry: widget.entry),
          ),
        )
        .then((_) => _reloadStatus());
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }

    if (!await File(widget.entry.audioPath).exists()) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音声ファイルが見つかりません。')));
      return;
    }

    await _player.setFilePath(widget.entry.audioPath);
    await _player.play();
  }

  Future<void> _confirmAndDeleteEntry() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('録音を削除しますか？'),
          content: const Text('この操作は取り消せません。音声ファイルとクラウド上の録音データも削除されます。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteEntry();
    }
  }

  Future<void> _deleteEntry() async {
    setState(() {
      _isDeleting = true;
    });
    await _player.stop();
    await RecordingStore.instance.delete(widget.entry);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}/$month/$day $hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RecordingCloudStatus {
  const _RecordingCloudStatus({
    required this.isSynced,
    required this.hasCorrection,
  });

  final bool isSynced;
  final bool hasCorrection;
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.status});

  final _RecordingCloudStatus? status;

  @override
  Widget build(BuildContext context) {
    final isLoading = status == null;
    final isSynced = status?.isSynced ?? false;
    final hasCorrection = status?.hasCorrection ?? false;
    final canAnalyze = isSynced || hasCorrection;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatusChip(
              icon: isLoading
                  ? Icons.hourglass_empty
                  : isSynced
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_off_outlined,
              label: isLoading
                  ? '状態確認中'
                  : isSynced
                  ? 'クラウド同期済み'
                  : '未同期',
            ),
            _StatusChip(
              icon: hasCorrection
                  ? Icons.auto_awesome
                  : Icons.auto_awesome_outlined,
              label: hasCorrection ? '添削保存済み' : '未添削',
            ),
            _StatusChip(
              icon: canAnalyze
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              label: canAnalyze ? 'AI解析可能' : '同期後にAI解析可能',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}
