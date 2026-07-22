import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

import '../../core/utils/japan_time.dart';
import '../../l10n/app_localizations.dart';

import '../correction/correction_result_page.dart';
import '../correction/repositories/correction_repository.dart';
import '../recording/data/recording_store.dart';
import '../recording/models/record_entry.dart';
import '../recording/repositories/recording_repository.dart';
import '../settings/models/app_language.dart';

class HistoryDetailPage extends StatefulWidget {
  const HistoryDetailPage({
    required this.entry,
    this.onClose,
    this.onChanged,
    super.key,
  });

  final RecordEntry entry;
  final VoidCallback? onClose;
  final VoidCallback? onChanged;

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  final _player = AudioPlayer();
  final _recordingRepository = SupabaseRecordingRepository();
  final _correctionRepository = CorrectionRepository();
  bool _isPlaying = false;
  bool _isDeleting = false;
  bool _showCorrection = false;
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

  @override
  void didUpdateWidget(covariant HistoryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id == widget.entry.id) {
      return;
    }
    _player.stop();
    setState(() {
      _isPlaying = false;
      _isDeleting = false;
      _showCorrection = false;
      _statusFuture = _loadStatus();
    });
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
    final l10n = AppLocalizations.of(context);
    if (_showCorrection) {
      return CorrectionResultPage(
        entry: widget.entry,
        onClose: _closeCorrectionResult,
      );
    }

    final entry = widget.entry;

    return Scaffold(
      appBar: AppBar(
        leading: widget.onClose == null
            ? null
            : IconButton(
                tooltip: l10n.backToHistory,
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onClose,
              ),
        title: Text(l10n.recordingDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.refreshStatus,
            icon: const Icon(Icons.refresh),
            onPressed: _reloadStatus,
          ),
          IconButton(
            tooltip: l10n.delete,
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
            label: l10n.recordingDuration,
            value: _formatDuration(entry.duration),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.translate,
            label: l10n.learningLanguage,
            value: _languageName(l10n, entry.language),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.folder_outlined,
            label: l10n.audioFile,
            value: entry.audioPath,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.viewAiCorrection),
            onPressed: _openCorrectionResult,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            label: Text(_isPlaying ? l10n.pause : l10n.play),
            onPressed: _togglePlayback,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.deleteRecording),
            onPressed: _isDeleting ? null : _confirmAndDeleteEntry,
          ),
        ],
      ),
    );
  }

  void _openCorrectionResult() {
    setState(() {
      _showCorrection = true;
    });
  }

  void _closeCorrectionResult() {
    setState(() {
      _showCorrection = false;
    });
    _reloadStatus();
    widget.onChanged?.call();
  }

  Future<void> _togglePlayback() async {
    final l10n = AppLocalizations.of(context);
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
      ).showSnackBar(SnackBar(content: Text(l10n.audioFileMissing)));
      return;
    }

    await _player.setFilePath(widget.entry.audioPath);
    await _player.play();
  }

  Future<void> _confirmAndDeleteEntry() async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteRecordingTitle),
          content: Text(l10n.deleteRecordingDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
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
      widget.onChanged?.call();
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = JapanTime.from(dateTime);
    return DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(local);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _languageName(AppLocalizations l10n, String value) {
    final code = AppLanguage.parse(value)?.code ?? value;
    return l10n.languageName(code == 'zh-Hans' ? 'zhHans' : code);
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
    final l10n = AppLocalizations.of(context);
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
                  ? l10n.checkingStatus
                  : isSynced
                  ? l10n.cloudSynced
                  : l10n.notSynced,
            ),
            _StatusChip(
              icon: hasCorrection
                  ? Icons.auto_awesome
                  : Icons.auto_awesome_outlined,
              label: hasCorrection ? l10n.correctionSaved : l10n.notCorrected,
            ),
            _StatusChip(
              icon: canAnalyze
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
              label: canAnalyze
                  ? l10n.aiAnalysisAvailable
                  : l10n.aiAnalysisAfterSync,
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
