import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../recording/models/record_entry.dart';
import '../vocabulary/repositories/vocabulary_repository.dart';
import 'models/ai_correction_result.dart';
import 'repositories/correction_repository.dart';
import 'services/edge_function_correction_service.dart';

class CorrectionResultPage extends StatefulWidget {
  const CorrectionResultPage({
    required this.entry,
    this.onClose,
    this.correctionRepository,
    this.correctionService,
    super.key,
  });

  final RecordEntry entry;
  final VoidCallback? onClose;
  final CorrectionRepository? correctionRepository;
  final EdgeFunctionCorrectionService? correctionService;

  @override
  State<CorrectionResultPage> createState() => _CorrectionResultPageState();
}

class _CorrectionResultPageState extends State<CorrectionResultPage> {
  late final EdgeFunctionCorrectionService _edgeCorrectionService;
  late final CorrectionRepository _correctionRepository;
  final _vocabularyRepository = VocabularyRepository();

  Future<_CorrectionViewData>? _resultFuture;
  bool _isAddingVocabulary = false;

  @override
  void initState() {
    super.initState();
    _correctionRepository =
        widget.correctionRepository ?? CorrectionRepository();
    _edgeCorrectionService =
        widget.correctionService ?? EdgeFunctionCorrectionService();
    _resultFuture = _loadSavedOrAnalyze();
  }

  Future<_CorrectionViewData> _loadSavedOrAnalyze() async {
    try {
      final saved = await _correctionRepository.fetchSavedResult(widget.entry);
      if (saved != null) {
        return _CorrectionViewData(
          result: saved,
          sourceLabel: 'saved',
          notice: null,
        );
      }
      if (await _correctionRepository.hasSavedResult(widget.entry)) {
        return const _CorrectionViewData(
          result: null,
          sourceLabel: 'mismatch',
          notice: null,
        );
      }
    } catch (_) {
      // 保存済み結果の取得に失敗した場合は通常解析へ進む。
    }
    return _analyzeAndSync();
  }

  Future<_CorrectionViewData> _analyzeAndSync() async {
    final result = await _edgeCorrectionService.analyze(widget.entry);
    const sourceLabel = 'edge';
    String? notice;

    try {
      await _correctionRepository.saveResult(
        entry: widget.entry,
        result: result,
      );
    } catch (error) {
      notice = _friendlyError(error);
    }

    return _CorrectionViewData(
      result: result,
      sourceLabel: sourceLabel,
      notice: notice,
    );
  }

  void _reanalyze() {
    setState(() {
      _resultFuture = _analyzeAndSync();
    });
  }

  Future<void> _addVocabulary(AiCorrectionResult result) async {
    setState(() {
      _isAddingVocabulary = true;
    });

    try {
      await _vocabularyRepository.addFromNotes(
        entry: widget.entry,
        notes: result.vocabularyNotes,
      );
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.vocabularyAdded)));
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.vocabularyAddFailed(_localizedError(l10n, error)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingVocabulary = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: widget.onClose == null
            ? null
            : IconButton(
                tooltip: l10n.backToRecordingDetails,
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onClose,
              ),
        title: Text(l10n.aiCorrectionTitle),
        actions: [
          IconButton(
            tooltip: l10n.reanalyze,
            icon: const Icon(Icons.refresh),
            onPressed: _reanalyze,
          ),
        ],
      ),
      body: FutureBuilder<_CorrectionViewData>(
        future: _resultFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _CorrectionErrorView(
              message: _localizedError(l10n, snapshot.error!),
              onClose: widget.onClose ?? () => Navigator.of(context).maybePop(),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _CorrectionLoadingView(message: l10n.correctionAnalyzing);
          }
          if (!snapshot.hasData) {
            return _CorrectionLoadingView(message: l10n.correctionAnalyzing);
          }

          final viewData = snapshot.data!;
          final result = viewData.result;
          if (result == null) {
            return _SavedCorrectionMismatchView(onReanalyze: _reanalyze);
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AnalysisSourceBanner(
                sourceLabel: viewData.sourceLabel,
                notice: viewData.notice,
                onRetry: viewData.sourceLabel == 'demo' ? _reanalyze : null,
              ),
              const SizedBox(height: 12),
              _ScoreHeader(score: result.score),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: _isAddingVocabulary
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.style_outlined),
                label: Text(l10n.addVocabularyNotes),
                onPressed: _isAddingVocabulary
                    ? null
                    : () => _addVocabulary(result),
              ),
              const SizedBox(height: 12),
              _ResultSection(
                icon: Icons.record_voice_over_outlined,
                title: l10n.transcript,
                child: Text(result.transcript),
              ),
              _ResultSection(
                icon: Icons.edit_note,
                title: l10n.correctedText,
                child: Text(result.correctedText),
              ),
              _ResultSection(
                icon: Icons.auto_awesome,
                title: l10n.naturalExpression,
                child: Text(result.naturalExpression),
              ),
              _ResultSection(
                icon: Icons.translate,
                title: l10n.translation,
                child: Text(result.translation),
              ),
              _ResultSection(
                icon: Icons.menu_book_outlined,
                title: l10n.grammarNotes,
                child: _BulletList(items: result.grammarNotes),
              ),
              _ResultSection(
                icon: Icons.style_outlined,
                title: l10n.vocabularyNotes,
                child: _BulletList(items: result.vocabularyNotes),
              ),
              _ResultSection(
                icon: Icons.favorite_outline,
                title: l10n.encouragement,
                child: Text(result.encouragement),
              ),
            ],
          );
        },
      ),
    );
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('429') ||
        message.contains('Too Many Requests') ||
        message.contains('本日の無料AI添削回数')) {
      return 'DAILY_AI_LIMIT_REACHED';
    }
    if (message.length <= 160) {
      return message;
    }
    return '${message.substring(0, 160)}...';
  }

  String _localizedError(AppLocalizations l10n, Object error) {
    final message = _friendlyError(error);
    return switch (message) {
      'DAILY_AI_LIMIT_REACHED' ||
      'DAILY_LIMIT_REACHED' => l10n.dailyAiLimitReached,
      'NO_RECOGNIZABLE_SPEECH' => l10n.noRecognizableSpeech,
      'UNSUPPORTED_LANGUAGE' => l10n.unsupportedCorrectionLanguage,
      'ANALYSIS_FAILED' => l10n.analysisFailed,
      'AUTH_REQUIRED' => l10n.correctionAuthRequired,
      'NETWORK_ERROR' => l10n.networkError,
      'INVALID_RESPONSE' => l10n.invalidServerResponse,
      _ => l10n.analysisFailed,
    };
  }
}

class _CorrectionLoadingView extends StatelessWidget {
  const _CorrectionLoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

class _CorrectionErrorView extends StatelessWidget {
  const _CorrectionErrorView({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.correctionLoadFailed, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.close),
              label: Text(l10n.close),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCorrectionMismatchView extends StatelessWidget {
  const _SavedCorrectionMismatchView({required this.onReanalyze});

  final VoidCallback onReanalyze;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate_outlined,
              size: 52,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.savedCorrectionLanguageMismatchTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.savedCorrectionLanguageMismatchDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.reanalysisConsumesUsage,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.reanalyzeInCurrentLanguage),
              onPressed: onReanalyze,
            ),
          ],
        ),
      ),
    );
  }
}

class _CorrectionViewData {
  const _CorrectionViewData({
    required this.result,
    required this.sourceLabel,
    required this.notice,
  });

  final AiCorrectionResult? result;
  final String sourceLabel;
  final String? notice;
}

class _AnalysisSourceBanner extends StatelessWidget {
  const _AnalysisSourceBanner({
    required this.sourceLabel,
    required this.notice,
    required this.onRetry,
  });

  final String sourceLabel;
  final String? notice;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDemo = sourceLabel == 'demo';
    final localizedSource = switch (sourceLabel) {
      'saved' => l10n.savedResultSource,
      'demo' => l10n.demoCorrectionSource,
      _ => l10n.edgeFunctionSource,
    };
    final localizedNotice = sourceLabel == 'saved'
        ? l10n.savedResultNotice
        : notice == null
        ? null
        : l10n.correctionSaveFailed(notice!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDemo ? Icons.science_outlined : Icons.cloud_done_outlined,
              color: isDemo ? colorScheme.tertiary : colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.analysisMethod(localizedSource),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (localizedNotice != null) ...[
                    const SizedBox(height: 4),
                    Text(localizedNotice, style: theme.textTheme.bodySmall),
                  ],
                  if (onRetry != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.runFullAnalysisAgain),
                      onPressed: onRetry,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  Center(
                    child: Text(
                      '$score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiScore,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.aiScoreDescription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('・'),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}
