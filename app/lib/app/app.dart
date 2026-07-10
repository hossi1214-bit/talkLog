import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'navigation.dart';
import 'startup_splash.dart';

class TalkLogApp extends StatelessWidget {
  const TalkLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalkLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StartupSplash(child: AppNavigation()),
    );
  }
}
