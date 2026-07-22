import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/record_entry.dart';
import '../repositories/recording_repository.dart';

class RecordingStore extends ChangeNotifier {
  RecordingStore._();

  static final RecordingStore instance = RecordingStore._();

  static const _entriesKey = 'record_entries';

  final List<RecordEntry> _entries = [];
  bool _isLoaded = false;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;
  String? _lastSyncError;
  String? _lastSyncMessage;
  int _cloudAudioStorageBytes = 0;
  RecordingRepository? _remoteRepository;

  List<RecordEntry> get entries => List.unmodifiable(_entries);
  bool get isLoaded => _isLoaded;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get lastSyncError => _lastSyncError;
  String? get lastSyncMessage => _lastSyncMessage;
  int get cloudAudioStorageBytes => _cloudAudioStorageBytes;

  RecordingRepository get _repository {
    return _remoteRepository ??= SupabaseRecordingRepository();
  }

  Future<void> load() async {
    if (_isLoaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final rawEntries = prefs.getStringList(_entriesKey) ?? const [];
    _entries
      ..clear()
      ..addAll(
        rawEntries.map((rawEntry) {
          final json = jsonDecode(rawEntry) as Map<String, dynamic>;
          return RecordEntry.fromJson(json);
        }),
      )
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> add(RecordEntry entry) async {
    await load();
    _upsertLocal(entry);
    _sortNewestFirst();
    await _save();
    notifyListeners();
    unawaited(_syncEntry(entry));
  }

  Future<void> delete(RecordEntry entry) async {
    await load();
    _entries.removeWhere((candidate) => candidate.id == entry.id);
    unawaited(_deleteRemoteEntry(entry));
    await _deleteAudioFile(entry.audioPath);
    await _save();
    notifyListeners();
  }

  Future<void> loadFromCloud() async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _lastSyncError = null;
    _lastSyncMessage = null;
    _cloudAudioStorageBytes = 0;
    notifyListeners();

    try {
      final remoteEntries = await _repository.fetchRecordings();
      _entries
        ..clear()
        ..addAll(remoteEntries)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoaded = true;
      await _save();
      _lastSyncedAt = DateTime.now();
      await refreshAudioStorageUsage(notify: false);
      _lastSyncMessage = remoteEntries.isEmpty
          ? 'RECORDINGS_CLOUD_EMPTY'
          : 'RECORDINGS_DOWNLOADED|${remoteEntries.length}';
    } catch (error) {
      _lastSyncError = _friendlyError(error);
      _entries.clear();
      _isLoaded = true;
      await _save();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    _entries.clear();
    _isLoaded = true;
    _isSyncing = false;
    _lastSyncedAt = null;
    _lastSyncError = null;
    _lastSyncMessage = null;
    _cloudAudioStorageBytes = 0;
    notifyListeners();
  }

  Future<void> syncAll() async {
    await load();
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _lastSyncError = null;
    _lastSyncMessage = null;
    _cloudAudioStorageBytes = 0;
    notifyListeners();

    try {
      for (final entry in List<RecordEntry>.from(_entries)) {
        await _repository.syncRecording(entry);
      }

      final remoteEntries = await _repository.fetchRecordings();
      var importedCount = 0;
      for (final entry in remoteEntries) {
        if (_upsertLocal(entry)) {
          importedCount++;
        }
      }
      _sortNewestFirst();
      await _save();

      _lastSyncedAt = DateTime.now();
      await refreshAudioStorageUsage(notify: false);
      _lastSyncMessage = importedCount == 0
          ? 'RECORDINGS_SYNCED'
          : 'RECORDINGS_IMPORTED|$importedCount';
    } catch (error) {
      _lastSyncError = _friendlyError(error);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncEntry(RecordEntry entry) async {
    try {
      await _repository.syncRecording(entry);
      _lastSyncedAt = DateTime.now();
      await refreshAudioStorageUsage(notify: false);
      _lastSyncError = null;
      _lastSyncMessage = 'RECORDINGS_SYNCED';
    } catch (error) {
      _lastSyncError = _friendlyError(error);
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshAudioStorageUsage({bool notify = true}) async {
    try {
      final usageBytes = await _repository.fetchAudioStorageUsageBytes();
      if (usageBytes == _cloudAudioStorageBytes) {
        return;
      }
      _cloudAudioStorageBytes = usageBytes;
      if (notify) {
        notifyListeners();
      }
    } catch (error) {
      _lastSyncError = _friendlyError(error);
      if (notify) {
        notifyListeners();
      }
    }
  }

  bool _upsertLocal(RecordEntry entry) {
    final index = _entries.indexWhere((candidate) => candidate.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
      return true;
    }

    final current = _entries[index];
    if (current.audioPath != entry.audioPath ||
        current.duration != entry.duration ||
        current.language != entry.language ||
        current.createdAt != entry.createdAt) {
      _entries[index] = entry;
    }
    return false;
  }

  void _sortNewestFirst() {
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _deleteRemoteEntry(RecordEntry entry) async {
    try {
      await _repository.deleteRecording(entry);
      await refreshAudioStorageUsage(notify: false);
    } catch (_) {
      // クラウド削除に失敗してもローカル削除は完了させる。
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 180) {
      return message;
    }
    return '${message.substring(0, 180)}...';
  }

  Future<void> _deleteAudioFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _entriesKey,
      _entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }
}
