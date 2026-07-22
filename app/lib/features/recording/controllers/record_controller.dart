import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/auth_session_service.dart';
import '../../settings/data/app_settings_store.dart';
import '../data/recording_store.dart';
import '../models/record_entry.dart';
import '../services/record_service.dart';

enum RecordErrorKind { permission, storageLimit, start, save, cancel }

class RecordController extends ChangeNotifier {
  RecordController({
    RecordService? recordService,
    RecordingStore? store,
    this._settingsStore,
  }) : _recordService = recordService ?? RecordService(),
       _store = store ?? RecordingStore.instance {
    _ensureSettingsStore();
  }

  final RecordService _recordService;
  final RecordingStore _store;
  AppSettingsStore? _settingsStore;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRecording = false;
  bool _isBusy = false;
  int _timerGeneration = 0;
  String? _errorMessage;
  RecordErrorKind? _errorKind;

  Duration get elapsed => _isRecording ? _elapsed : Duration.zero;
  bool get isRecording => _isRecording;
  bool get isBusy => _isBusy;
  String get learningLanguage => _settings.learningLanguage;
  String get learningLanguageCode => _settings.learningLanguageCode;
  String? get errorMessage => _errorMessage;
  RecordErrorKind? get errorKind => _errorKind;

  AppSettingsStore get _settings {
    return _settingsStore ??= AppSettingsStore.instance;
  }

  void _ensureSettingsStore() {
    final settings = _settings;
    settings.removeListener(notifyListeners);
    settings.addListener(notifyListeners);
    unawaited(settings.load());
  }

  Future<RecordEntry?> toggleRecording() async {
    _ensureSettingsStore();
    if (_isBusy) {
      return null;
    }

    if (_isRecording) {
      return stopRecording();
    }

    await startRecording();
    return null;
  }

  Future<void> startRecording() async {
    _ensureSettingsStore();
    if (_isRecording || _isBusy) {
      return;
    }

    _isBusy = true;
    _stopTimer();
    _elapsed = Duration.zero;
    _errorMessage = null;
    _errorKind = null;
    notifyListeners();

    try {
      await _settings.load();
      final storageLimit = AuthSessionService.instance.audioStorageLimitBytes;
      if (storageLimit != null) {
        await _store.refreshAudioStorageUsage(notify: false);
        if (_store.cloudAudioStorageBytes >= storageLimit) {
          throw const _StorageLimitReached();
        }
      }
      await _recordService.start();
      _isRecording = true;
      _startTimer();
    } on RecordPermissionException {
      _errorKind = RecordErrorKind.permission;
    } on _StorageLimitReached {
      _errorKind = RecordErrorKind.storageLimit;
    } on RecordStartException catch (error) {
      _errorKind = RecordErrorKind.start;
      _errorMessage = _friendlyError(error.message);
    } catch (error) {
      _errorKind = RecordErrorKind.start;
      _errorMessage = _friendlyError(error);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<RecordEntry?> stopRecording() async {
    _ensureSettingsStore();
    if (!_isRecording || _isBusy) {
      _stopRecordingClock();
      notifyListeners();
      return null;
    }

    _isBusy = true;
    final duration = _elapsed;
    final language = _settings.learningLanguageCode;
    _stopRecordingClock();
    notifyListeners();

    try {
      final audioPath = await _recordService.stop();
      final now = DateTime.now().toUtc();
      final entry = RecordEntry(
        id: const Uuid().v4(),
        createdAt: now,
        duration: duration,
        audioPath: audioPath,
        language: language,
      );
      await _store.add(entry);
      return entry;
    } on RecordSaveException catch (error) {
      _errorKind = RecordErrorKind.save;
      _errorMessage = _friendlyError(error.message);
    } catch (error) {
      _errorKind = RecordErrorKind.save;
      _errorMessage = _friendlyError(error);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> cancelRecording() async {
    _ensureSettingsStore();
    if (!_isRecording || _isBusy) {
      _stopRecordingClock();
      notifyListeners();
      return;
    }

    _isBusy = true;
    _stopRecordingClock();
    notifyListeners();

    try {
      await _recordService.cancel();
      _errorMessage = null;
      _errorKind = null;
    } on RecordSaveException catch (error) {
      _errorKind = RecordErrorKind.cancel;
      _errorMessage = _friendlyError(error.message);
    } catch (error) {
      _errorKind = RecordErrorKind.cancel;
      _errorMessage = _friendlyError(error);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    final generation = ++_timerGeneration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRecording || generation != _timerGeneration) {
        timer.cancel();
        return;
      }
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopRecordingClock() {
    _isRecording = false;
    _elapsed = Duration.zero;
    _stopTimer();
  }

  void _stopTimer() {
    _timerGeneration++;
    _timer?.cancel();
    _timer = null;
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 140) {
      return message;
    }
    return '${message.substring(0, 140)}...';
  }

  @override
  void dispose() {
    _settingsStore?.removeListener(notifyListeners);
    _stopTimer();
    unawaited(_recordService.dispose());
    super.dispose();
  }
}

class _StorageLimitReached implements Exception {
  const _StorageLimitReached();
}
