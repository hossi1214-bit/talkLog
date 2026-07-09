import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../settings/data/app_settings_store.dart';
import '../data/recording_store.dart';
import '../models/record_entry.dart';
import '../services/record_service.dart';

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

  Duration get elapsed => _isRecording ? _elapsed : Duration.zero;
  bool get isRecording => _isRecording;
  bool get isBusy => _isBusy;
  String get learningLanguage => _settings.learningLanguage;
  String? get errorMessage => _errorMessage;

  AppSettingsStore get _settings {
    return _settingsStore ??= AppSettingsStore.instance;
  }

  void _ensureSettingsStore() {
    final settings = _settings;
    settings.removeListener(notifyListeners);
    settings.addListener(notifyListeners);
    unawaited(settings.load());
  }

  Future<void> toggleRecording() async {
    _ensureSettingsStore();
    if (_isBusy) {
      return;
    }

    if (_isRecording) {
      await stopRecording();
      return;
    }

    await startRecording();
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
    notifyListeners();

    try {
      await _settings.load();
      await _recordService.start();
      _isRecording = true;
      _startTimer();
    } on RecordPermissionException {
      _errorMessage = '録音にはマイクの許可が必要です。Androidのアプリ情報からマイクを許可してください。';
    } on RecordStartException catch (error) {
      _errorMessage = '録音を開始できませんでした: ${_friendlyError(error.message)}';
    } catch (error) {
      _errorMessage = '録音を開始できませんでした: ${_friendlyError(error)}';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    _ensureSettingsStore();
    if (!_isRecording || _isBusy) {
      _stopRecordingClock();
      notifyListeners();
      return;
    }

    _isBusy = true;
    final duration = _elapsed;
    final language = _settings.learningLanguage;
    _stopRecordingClock();
    notifyListeners();

    try {
      final audioPath = await _recordService.stop();
      final now = DateTime.now().toUtc();
      await _store.add(
        RecordEntry(
          id: const Uuid().v4(),
          createdAt: now,
          duration: duration,
          audioPath: audioPath,
          language: language,
        ),
      );
    } on RecordSaveException catch (error) {
      _errorMessage = '録音を保存できませんでした: ${_friendlyError(error.message)}';
    } catch (error) {
      _errorMessage = '録音を保存できませんでした: ${_friendlyError(error)}';
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
