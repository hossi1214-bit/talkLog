import 'dart:async';

import 'package:flutter/material.dart';

import '../core/services/auth_session_service.dart';
import '../features/history/history_page.dart';
import '../features/home/home_page.dart';
import '../features/progress/progress_page.dart';
import '../features/recording/data/recording_store.dart';
import '../features/recording/record_page.dart';
import '../features/settings/data/app_settings_store.dart';
import '../features/settings/settings_page.dart';
import '../features/vocabulary/vocabulary_page.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  static const _settingsIndex = 5;

  final _authSessionService = AuthSessionService.instance;
  final _recordingStore = RecordingStore.instance;
  final _settingsStore = AppSettingsStore.instance;

  int _currentIndex = _settingsIndex;
  String? _loadedUserId;

  late final List<Widget> _pages;

  bool get _isLoggedIn => _authSessionService.isEmailSignedIn;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onStartRecording: _openRecording),
      const RecordPage(),
      const HistoryPage(),
      const VocabularyPage(),
      const ProgressPage(),
      const SettingsPage(),
    ];
    _authSessionService.addListener(_handleAuthChanged);
    unawaited(_initializeForCurrentSession());
  }

  @override
  void dispose() {
    _authSessionService.removeListener(_handleAuthChanged);
    super.dispose();
  }

  Future<void> _initializeForCurrentSession() async {
    await _authSessionService.initializeSession();
    await _loadDataForLoggedInUser();
  }

  void _handleAuthChanged() {
    if (!_isLoggedIn && _currentIndex != _settingsIndex) {
      setState(() {
        _currentIndex = _settingsIndex;
      });
    } else if (mounted) {
      setState(() {});
    }
    unawaited(_loadDataForLoggedInUser());
  }

  Future<void> _loadDataForLoggedInUser() async {
    final userId = _authSessionService.userId;
    if (!_authSessionService.isEmailSignedIn || userId == null) {
      _loadedUserId = null;
      await _recordingStore.clearLocal();
      return;
    }
    if (_loadedUserId == userId) {
      return;
    }
    _loadedUserId = userId;
    await _recordingStore.clearLocal();
    await Future.wait([
      _recordingStore.loadFromCloud(),
      _settingsStore.syncFromCloud(),
    ]);
  }

  void _openRecording() {
    if (!_isLoggedIn) {
      _openSettings();
      return;
    }
    setState(() {
      _currentIndex = 1;
    });
  }

  void _openSettings() {
    setState(() {
      _currentIndex = _settingsIndex;
    });
  }

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'ホーム'),
    BottomNavigationBarItem(icon: Icon(Icons.mic_none), label: '録音'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: '履歴'),
    BottomNavigationBarItem(icon: Icon(Icons.style_outlined), label: '単語帳'),
    BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '進捗'),
    BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: '設定'),
  ];

  @override
  Widget build(BuildContext context) {
    final body = _isLoggedIn
        ? IndexedStack(index: _currentIndex, children: _pages)
        : const SettingsPage();

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: _items,
        onTap: (index) {
          if (!_isLoggedIn && index != _settingsIndex) {
            setState(() {
              _currentIndex = _settingsIndex;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('利用するにはメールログインしてください。')),
            );
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
