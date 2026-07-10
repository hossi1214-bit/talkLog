import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../correction/repositories/correction_repository.dart';
import '../recording/data/recording_store.dart';
import '../recording/models/record_entry.dart';
import '../recording/widgets/sync_status_banner.dart';
import '../settings/data/app_settings_store.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _store = RecordingStore.instance;
  final _player = AudioPlayer();
  final _correctionRepository = CorrectionRepository();
  final _searchController = TextEditingController();

  String? _playingId;
  String _query = '';
  String? _languageFilter;
  bool _showCorrectedOnly = false;
  bool _isDeletingSelected = false;
  _DateRangeFilter _dateRangeFilter = _DateRangeFilter.all;
  _DurationFilter _durationFilter = _DurationFilter.all;
  Set<String> _correctedIds = const {};
  final Set<String> _selectedIds = {};
  RecordEntry? _detailEntry;

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _store.addListener(_handleStoreChanged);
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() {
          _playingId = null;
        });
      }
    });
    _store.load();
    _loadCorrectedIds();
  }

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    _searchController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadCorrectedIds() async {
    try {
      final ids = await _correctionRepository.fetchCorrectedRecordingIds();
      if (mounted) {
        setState(() {
          _correctedIds = ids;
        });
      }
    } catch (_) {
      // フィルター用の補助情報なので、取得失敗時は未添削扱いにする。
    }
  }

  void _handleStoreChanged() {
    if (mounted) {
      final entryIds = _store.entries.map((entry) => entry.id).toSet();
      setState(() {
        _selectedIds.removeWhere((id) => !entryIds.contains(id));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailEntry = _detailEntry;
    if (detailEntry != null) {
      return HistoryDetailPage(
        entry: detailEntry,
        onClose: _closeDetails,
        onChanged: _loadCorrectedIds,
      );
    }

    final entries = _filteredEntries(_store.entries);

    return Scaffold(
      appBar: AppBar(
        leading: _isSelectionMode
            ? IconButton(
                tooltip: '選択を解除',
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(_isSelectionMode ? '${_selectedIds.length}件選択中' : '履歴'),
        actions: _isSelectionMode
            ? [
                IconButton(
                  tooltip: '表示中の履歴をすべて選択',
                  icon: const Icon(Icons.select_all),
                  onPressed: entries.isEmpty ? null : () => _selectAll(entries),
                ),
                IconButton(
                  tooltip: '選択した履歴を削除',
                  icon: _isDeletingSelected
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  onPressed: _isDeletingSelected
                      ? null
                      : _confirmAndDeleteSelected,
                ),
              ]
            : [
                IconButton(
                  tooltip: '絞り込みをリセット',
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  onPressed: _hasActiveFilters ? _resetFilters : null,
                ),
                IconButton(
                  tooltip: '添削状態を再取得',
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCorrectedIds,
                ),
              ],
      ),
      body: !_store.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: '日付・言語で検索',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      FilterChip(
                        label: const Text('添削済みのみ'),
                        selected: _showCorrectedOnly,
                        onSelected: (value) {
                          setState(() {
                            _showCorrectedOnly = value;
                            _selectedIds.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('すべて'),
                        selected: _languageFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _languageFilter = null;
                            _selectedIds.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      for (final language
                          in AppSettingsStore.supportedLanguages) ...[
                        ChoiceChip(
                          label: Text(language),
                          selected: _languageFilter == language,
                          onSelected: (_) {
                            setState(() {
                              _languageFilter = language;
                              _selectedIds.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final filter in _DateRangeFilter.values) ...[
                        ChoiceChip(
                          label: Text(filter.label),
                          selected: _dateRangeFilter == filter,
                          onSelected: (_) {
                            setState(() {
                              _dateRangeFilter = filter;
                              _selectedIds.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final filter in _DurationFilter.values) ...[
                        ChoiceChip(
                          label: Text(filter.label),
                          selected: _durationFilter == filter,
                          onSelected: (_) {
                            setState(() {
                              _durationFilter = filter;
                              _selectedIds.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                if (!_isSelectionMode) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SyncStatusBanner(store: _store),
                  ),
                ],
                if (_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '削除したい履歴を選択してください。',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearSelection,
                          child: const Text('解除'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _store.entries.isEmpty
                      ? const Center(child: Text('録音はまだありません。'))
                      : entries.isEmpty
                      ? const Center(child: Text('条件に合う履歴はありません。'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: entries.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final isPlaying = _playingId == entry.id;
                            final isCorrected = _correctedIds.contains(
                              entry.id,
                            );
                            final isSelected = _selectedIds.contains(entry.id);
                            return Card(
                              child: ListTile(
                                selected: isSelected,
                                leading: _isSelectionMode
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (_) =>
                                            _toggleSelection(entry),
                                      )
                                    : IconButton.filledTonal(
                                        tooltip: isPlaying ? '一時停止' : '再生',
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                        onPressed: () => _togglePlayback(entry),
                                      ),
                                title: Text(_formatDateTime(entry.createdAt)),
                                subtitle: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _SmallStatus(label: entry.language),
                                    _SmallStatus(
                                      label: _formatDuration(entry.duration),
                                    ),
                                    _SmallStatus(
                                      label: isCorrected ? '添削済み' : '未添削',
                                      icon: isCorrected
                                          ? Icons.auto_awesome
                                          : Icons.auto_awesome_outlined,
                                    ),
                                  ],
                                ),
                                trailing: _isSelectionMode
                                    ? null
                                    : PopupMenuButton<_HistoryAction>(
                                        tooltip: 'その他',
                                        onSelected: (action) =>
                                            _handleAction(action, entry),
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: _HistoryAction.details,
                                            child: Text('詳細'),
                                          ),
                                          PopupMenuItem(
                                            value: _HistoryAction.select,
                                            child: Text('選択'),
                                          ),
                                          PopupMenuItem(
                                            value: _HistoryAction.delete,
                                            child: Text('削除'),
                                          ),
                                        ],
                                      ),
                                onTap: _isSelectionMode
                                    ? () => _toggleSelection(entry)
                                    : () => _openDetails(entry),
                                onLongPress: () => _toggleSelection(entry),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  bool get _hasActiveFilters =>
      _query.isNotEmpty ||
      _languageFilter != null ||
      _showCorrectedOnly ||
      _dateRangeFilter != _DateRangeFilter.all ||
      _durationFilter != _DurationFilter.all;

  List<RecordEntry> _filteredEntries(List<RecordEntry> entries) {
    return entries.where((entry) {
      if (_languageFilter != null && entry.language != _languageFilter) {
        return false;
      }
      if (_showCorrectedOnly && !_correctedIds.contains(entry.id)) {
        return false;
      }
      if (!_dateRangeFilter.matches(entry.createdAt)) {
        return false;
      }
      if (!_durationFilter.matches(entry.duration)) {
        return false;
      }
      if (_query.isNotEmpty) {
        final target = '${entry.language} ${_formatDateTime(entry.createdAt)}'
            .toLowerCase();
        if (!target.contains(_query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _searchController.clear();
      _languageFilter = null;
      _showCorrectedOnly = false;
      _dateRangeFilter = _DateRangeFilter.all;
      _durationFilter = _DurationFilter.all;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(RecordEntry entry) {
    setState(() {
      if (_selectedIds.contains(entry.id)) {
        _selectedIds.remove(entry.id);
      } else {
        _selectedIds.add(entry.id);
      }
    });
  }

  void _selectAll(List<RecordEntry> entries) {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(entries.map((entry) => entry.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _togglePlayback(RecordEntry entry) async {
    if (_playingId == entry.id && _player.playing) {
      await _player.pause();
      setState(() {
        _playingId = null;
      });
      return;
    }

    if (!await File(entry.audioPath).exists()) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('音声ファイルが見つかりません。')));
      return;
    }

    await _player.setFilePath(entry.audioPath);
    await _player.play();
    if (mounted) {
      setState(() {
        _playingId = entry.id;
      });
    }
  }

  Future<void> _handleAction(_HistoryAction action, RecordEntry entry) async {
    switch (action) {
      case _HistoryAction.details:
        _openDetails(entry);
      case _HistoryAction.select:
        _toggleSelection(entry);
      case _HistoryAction.delete:
        await _confirmAndDeleteEntry(entry);
    }
  }

  Future<void> _confirmAndDeleteEntry(RecordEntry entry) async {
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
      await _deleteEntry(entry);
    }
  }

  Future<void> _confirmAndDeleteSelected() async {
    final selectedEntries = _store.entries
        .where((entry) => _selectedIds.contains(entry.id))
        .toList(growable: false);
    if (selectedEntries.isEmpty) {
      _clearSelection();
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${selectedEntries.length}件の録音を削除しますか？'),
          content: const Text('この操作は取り消せません。選択した音声ファイルとクラウド上の録音データも削除されます。'),
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
      await _deleteSelectedEntries(selectedEntries);
    }
  }

  Future<void> _deleteEntry(RecordEntry entry) async {
    if (_playingId == entry.id) {
      await _player.stop();
      _playingId = null;
    }
    await _store.delete(entry);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('録音を削除しました。')));
    }
  }

  Future<void> _deleteSelectedEntries(List<RecordEntry> entries) async {
    setState(() {
      _isDeletingSelected = true;
    });

    try {
      if (_playingId != null &&
          entries.any((entry) => entry.id == _playingId)) {
        await _player.stop();
        _playingId = null;
      }
      for (final entry in entries) {
        await _store.delete(entry);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedIds.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${entries.length}件の録音を削除しました。')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingSelected = false;
        });
      }
    }
  }

  void _openDetails(RecordEntry entry) {
    setState(() {
      _detailEntry = entry;
      _selectedIds.clear();
    });
  }

  void _closeDetails() {
    setState(() {
      _detailEntry = null;
    });
    _loadCorrectedIds();
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

class _SmallStatus extends StatelessWidget {
  const _SmallStatus({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    if (icon == null) {
      return Text(label, style: textStyle);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 3),
        Text(label, style: textStyle),
      ],
    );
  }
}

enum _HistoryAction { details, select, delete }

enum _DateRangeFilter {
  all('期間: すべて'),
  today('今日'),
  sevenDays('7日以内'),
  thirtyDays('30日以内');

  const _DateRangeFilter(this.label);

  final String label;

  bool matches(DateTime value) {
    final now = DateTime.now();
    final date = DateTime(value.year, value.month, value.day);
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      _DateRangeFilter.all => true,
      _DateRangeFilter.today => date == today,
      _DateRangeFilter.sevenDays => !date.isBefore(
        today.subtract(const Duration(days: 6)),
      ),
      _DateRangeFilter.thirtyDays => !date.isBefore(
        today.subtract(const Duration(days: 29)),
      ),
    };
  }
}

enum _DurationFilter {
  all('長さ: すべて'),
  short('1分未満'),
  medium('1〜3分'),
  long('3分以上');

  const _DurationFilter(this.label);

  final String label;

  bool matches(Duration duration) {
    return switch (this) {
      _DurationFilter.all => true,
      _DurationFilter.short => duration < const Duration(minutes: 1),
      _DurationFilter.medium =>
        duration >= const Duration(minutes: 1) &&
            duration < const Duration(minutes: 3),
      _DurationFilter.long => duration >= const Duration(minutes: 3),
    };
  }
}
