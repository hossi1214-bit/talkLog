import 'package:flutter/material.dart';

import 'controllers/record_controller.dart';
import 'data/recording_store.dart';
import 'services/speaking_draft_service.dart';
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
  final _draftService = SpeakingDraftService();
  final _intentController = TextEditingController();

  bool _isCreatingDraft = false;
  String? _draftText;
  String? _draftError;

  @override
  void initState() {
    super.initState();
    _controller = RecordController();
    _recordingStore.addListener(_handleRecordingStoreChanged);
  }

  @override
  void dispose() {
    _intentController.dispose();
    _recordingStore.removeListener(_handleRecordingStoreChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleRecordingStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _createSpeakingDraft() async {
    final intent = _intentController.text.trim();
    if (intent.isEmpty) {
      setState(() {
        _draftError = '日本語で言いたいことを入力してください。';
      });
      return;
    }

    setState(() {
      _isCreatingDraft = true;
      _draftError = null;
    });

    try {
      final draft = await _draftService.createDraft(
        japaneseText: intent,
        language: _controller.learningLanguage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _draftText = draft;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _draftError = _friendlyError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingDraft = false;
        });
      }
    }
  }

  void _clearDraft() {
    setState(() {
      _intentController.clear();
      _draftText = null;
      _draftError = null;
    });
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
                  constraints: const BoxConstraints(maxWidth: 380),
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
                      if (_controller.isRecording) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('録音をキャンセル'),
                          onPressed: _controller.isBusy
                              ? null
                              : _controller.cancelRecording,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _SpeakingDraftPanel(
                        controller: _intentController,
                        language: _controller.learningLanguage,
                        draftText: _draftText,
                        errorText: _draftError,
                        isLoading: _isCreatingDraft,
                        onCreate: _isCreatingDraft
                            ? null
                            : _createSpeakingDraft,
                        onClear: _clearDraft,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _controller.isBusy
                            ? '少しお待ちください'
                            : _controller.isRecording
                            ? '文章を見ながら話して、停止で保存します'
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

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 140) {
      return message;
    }
    return '${message.substring(0, 140)}...';
  }
}

class _SpeakingDraftPanel extends StatelessWidget {
  const _SpeakingDraftPanel({
    required this.controller,
    required this.language,
    required this.draftText,
    required this.errorText,
    required this.isLoading,
    required this.onCreate,
    required this.onClear,
  });

  final TextEditingController controller;
  final String language;
  final String? draftText;
  final String? errorText;
  final bool isLoading;
  final VoidCallback? onCreate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('何を言うか考える', style: theme.textTheme.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: '言いたいこと（日本語）',
                hintText: '例: 今日は仕事で疲れたけど、英語の練習を続けたい',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: Text(isLoading ? '作成中...' : '$language の練習文を作る'),
              onPressed: onCreate,
            ),
            if (errorText != null) ...[
              const SizedBox(height: 10),
              Text(errorText!, style: TextStyle(color: colorScheme.error)),
            ],
            if (draftText != null && draftText!.isNotEmpty) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('読み上げメモ', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 6),
                      SelectableText(
                        draftText!,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('クリア'),
                          onPressed: onClear,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
