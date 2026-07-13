import 'dart:async';

import 'package:flutter/material.dart';

class StartupSplash extends StatefulWidget {
  const StartupSplash({required this.child, super.key});

  final Widget child;

  @override
  State<StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends State<StartupSplash> {
  static const _minimumDisplayDuration = Duration(milliseconds: 1200);
  static const _fadeDuration = Duration(milliseconds: 280);

  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    unawaited(_hideSplashAfterDelay());
  }

  Future<void> _hideSplashAfterDelay() async {
    await Future<void>.delayed(_minimumDisplayDuration);
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !_showSplash,
          child: AnimatedOpacity(
            opacity: _showSplash ? 1 : 0,
            duration: _fadeDuration,
            curve: Curves.easeOut,
            child: const _SplashView(),
          ),
        ),
      ],
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox.square(
          dimension: 168,
          child: Image(
            image: AssetImage('assets/images/talkLog_main.png'),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
