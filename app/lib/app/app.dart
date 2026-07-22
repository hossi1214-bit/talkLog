import 'dart:async';

import 'package:flutter/material.dart';

import '../features/settings/data/app_settings_store.dart';
import '../l10n/app_localizations.dart';
import 'app_theme.dart';
import 'navigation.dart';
import 'startup_splash.dart';

class TalkLogApp extends StatefulWidget {
  const TalkLogApp({super.key});

  @override
  State<TalkLogApp> createState() => _TalkLogAppState();
}

class _TalkLogAppState extends State<TalkLogApp> {
  final _settings = AppSettingsStore.instance;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_handleSettingsChanged);
    unawaited(_settings.load());
  }

  @override
  void dispose() {
    _settings.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  void _handleSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: Locale(_settings.baseLocaleCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const StartupSplash(child: AppNavigation()),
    );
  }
}
