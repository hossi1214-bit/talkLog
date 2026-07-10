import 'package:flutter/material.dart';

import 'controllers/record_controller.dart';
import 'data/recording_store.dart';
import 'widgets/record_button.dart';
import 'widgets/sync_status_banner.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late final RecordController _controller;
  final _recordingStore = RecordingStore.instance;

  @override
  void initState() {
    super.initState();
    _controller = RecordController();
    _recordingStore.addListener(_handleRecordingStoreChanged);
  }

  @override
  void dispose() {
    _recordingStore.removeListener(_handleRecordingStoreChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleRecordingStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('録音')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _controller.isBusy
                            ? '処理中です'
                            : _controller.isRecording
                            ? '録音中'
                            : '録音できます',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _controller.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: _controller.isRecording
                            ? const _TalkingImage()
                            : const SizedBox(height: 20),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _formatDuration(_controller.elapsed),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      const SizedBox(height: 36),
                      RecordButton(
                        isRecording: _controller.isRecording,
                        isBusy: _controller.isBusy,
                        onPressed: _controller.toggleRecording,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _controller.isBusy
                            ? '少しお待ちください'
                            : _controller.isRecording
                            ? 'タップして停止'
                            : 'タップして録音開始',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 28),
                      _LanguageChip(label: _controller.learningLanguage),
                      const SizedBox(height: 16),
                      SyncStatusBanner(store: _recordingStore),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _TalkingImage extends StatelessWidget {
  const _TalkingImage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('talking-image'),
      padding: const EdgeInsets.only(top: 20),
      child: Image.asset(
        'assets/images/talkLog_talking.png',
        width: 148,
        height: 148,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.translate, size: 18),
      label: Text(label),
    );
  }
}
