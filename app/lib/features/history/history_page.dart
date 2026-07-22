import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

import '../../core/utils/japan_time.dart';
import '../../l10n/app_localizations.dart';

import '../correction/repositories/correction_repository.dart';
import '../recording/data/recording_store.dart';
import '../recording/models/record_entry.dart';
import '../recording/widgets/sync_status_banner.dart';
import '../settings/models/app_language.dart';
import 'history_detail_page.dart';

class HistoryPageController extends ChangeNotifier {
  RecordEntry? _pendingDetailEntry;

  void openDetails(RecordEntry entry) {
    _pendingDetailEntry = entry;
    notifyListeners();
  }

  RecordEntry? takePendingDetailEntry() {
    final entry = _pendingDetailEntry;
    _pendingDetailEntry = null;
    return entry;
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({this.controller, super.key});

  final HistoryPageController? controller;

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
    widget.controller?.addListener(_handleControllerChanged);
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
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller?.removeListener(_handleControllerChanged);
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_handleStoreChanged);
    widget.controller?.removeListener(_handleControllerChanged);
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

  void _handleControllerChanged() {
    final entry = widget.controller?.takePendingDetailEntry();
    if (entry == null || !mounted) {
      return;
    }
    setState(() {
      _detailEntry = entry;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailEntry = _detailEntry;
    if (detailEntry != null) {
      return HistoryDetailPage(
        key: ValueKey(detailEntry.id),
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
                tooltip: l10n.clearSelection,
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(
          _isSelectionMode
              ? l10n.historySelected(_selectedIds.length)
              : l10n.historyTitle,
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  tooltip: l10n.selectAllVisible,
                  icon: const Icon(Icons.select_all),
                  onPressed: entries.isEmpty ? null : () => _selectAll(entries),
                ),
                IconButton(
                  tooltip: l10n.deleteSelected,
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
                  tooltip: l10n.resetFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  onPressed: _hasActiveFilters ? _resetFilters : null,
                ),
                IconButton(
                  tooltip: l10n.refreshCorrectionStatus,
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
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.historySearchHint,
                      border: const OutlineInputBorder(),
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
                        label: Text(l10n.correctedOnly),
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
                        label: Text(l10n.all),
                        selected: _languageFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _languageFilter = null;
                            _selectedIds.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      for (final language in AppLanguage.values) ...[
                        ChoiceChip(
                          label: Text(_languageName(l10n, language.code)),
                          selected: _languageFilter == language.code,
                          onSelected: (_) {
                            setState(() {
                              _languageFilter = language.code;
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
                          label: Text(filter.label(l10n)),
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
                          label: Text(filter.label(l10n)),
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
                            l10n.selectHistoryHelp,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearSelection,
                          child: Text(l10n.releaseSelection),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _store.entries.isEmpty
                      ? Center(child: Text(l10n.noRecordings))
                      : entries.isEmpty
                      ? Center(child: Text(l10n.noMatchingHistory))
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
                                        tooltip: isPlaying
                                            ? l10n.pause
                                            : l10n.play,
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
                                    _SmallStatus(
                                      label: _languageName(
                                        l10n,
                                        AppLanguage.parse(
                                              entry.language,
                                            )?.code ??
                                            entry.language,
                                      ),
                                    ),
                                    _SmallStatus(
                                      label: _formatDuration(entry.duration),
                                    ),
                                    _SmallStatus(
                                      label: isCorrected
                                          ? l10n.corrected
                                          : l10n.notCorrected,
                                      icon: isCorrected
                                          ? Icons.auto_awesome
                                          : Icons.auto_awesome_outlined,
                                    ),
                                  ],
                                ),
                                trailing: _isSelectionMode
                                    ? null
                                    : PopupMenuButton<_HistoryAction>(
                                        tooltip: l10n.more,
                                        onSelected: (action) =>
                                            _handleAction(action, entry),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: _HistoryAction.details,
                                            child: Text(l10n.details),
                                          ),
                                          PopupMenuItem(
                                            value: _HistoryAction.select,
                                            child: Text(l10n.select),
                                          ),
                                          PopupMenuItem(
                                            value: _HistoryAction.delete,
                                            child: Text(l10n.delete),
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
      if (_languageFilter != null &&
          AppLanguage.parse(entry.language)?.code != _languageFilter) {
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
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).audioFileMissing)),
      );
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
      await _deleteEntry(entry);
    }
  }

  Future<void> _confirmAndDeleteSelected() async {
    final l10n = AppLocalizations.of(context);
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
          title: Text(l10n.deleteSelectedTitle(selectedEntries.length)),
          content: Text(l10n.deleteSelectedDescription),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).recordingDeleted)),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).recordingsDeleted(entries.length),
          ),
        ),
      );
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

  String _languageName(AppLocalizations l10n, String code) {
    return l10n.languageName(code == 'zh-Hans' ? 'zhHans' : code);
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
  all,
  today,
  sevenDays,
  thirtyDays;

  String label(AppLocalizations l10n) => switch (this) {
    _DateRangeFilter.all => l10n.dateAll,
    _DateRangeFilter.today => l10n.today,
    _DateRangeFilter.sevenDays => l10n.withinSevenDays,
    _DateRangeFilter.thirtyDays => l10n.withinThirtyDays,
  };

  bool matches(DateTime value) {
    final date = JapanTime.dateOnly(value);
    final today = JapanTime.today();
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
  all,
  short,
  medium,
  long;

  String label(AppLocalizations l10n) => switch (this) {
    _DurationFilter.all => l10n.durationAll,
    _DurationFilter.short => l10n.underOneMinute,
    _DurationFilter.medium => l10n.oneToThreeMinutes,
    _DurationFilter.long => l10n.threeMinutesOrMore,
  };

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
