import 'package:flutter/material.dart';

import 'controllers/record_controller.dart';
import 'data/recording_store.dart';
import 'models/record_entry.dart';
import 'services/speaking_draft_service.dart';
import 'widgets/record_button.dart';
import 'widgets/sync_status_banner.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({this.onRecordingSaved, super.key});

  final ValueChanged<RecordEntry>? onRecordingSaved;

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
    FocusManager.instance.primaryFocus?.unfocus();

    final intent = _intentController.text.trim();
    if (intent.isEmpty) {
      setState(() {
        _draftText = null;
        _draftError = '日本語で言いたいことを入力してください。';
      });
      return;
    }

    setState(() {
      _isCreatingDraft = true;
      _draftText = null;
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
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _intentController.clear();
      _draftText = null;
      _draftError = null;
    });
  }

  Future<void> _toggleRecording() async {
    final wasRecording = _controller.isRecording;
    final savedEntry = await _controller.toggleRecording();
    if (!mounted || savedEntry == null || !wasRecording) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(const SnackBar(content: Text('録音を保存しました。')));
    widget.onRecordingSaved?.call(savedEntry);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('録音')),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    24 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
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
                          onPressed: _toggleRecording,
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
                              ? '練習文を見ながら話して、停止で保存します'
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
            if (draftText != null && draftText!.isNotEmpty) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                  border: Border.all(color: colorScheme.primaryContainer),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text('見ながら話す文', style: theme.textTheme.labelLarge),
                          const Spacer(),
                          IconButton(
                            tooltip: 'クリア',
                            icon: const Icon(Icons.close),
                            onPressed: onClear,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        draftText!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                labelText: '言いたいこと（日本語）',
                hintText: '例: 今日は仕事で疲れたけど、英語の練習を続けたい',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: 'キーボードを閉じる',
                  icon: const Icon(Icons.keyboard_hide_outlined),
                  onPressed: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
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
