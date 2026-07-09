import 'package:flutter/material.dart';

import '../../core/services/auth_session_service.dart';
import '../recording/models/record_entry.dart';
import '../vocabulary/repositories/vocabulary_repository.dart';
import 'models/ai_correction_result.dart';
import 'repositories/correction_repository.dart';
import 'services/dummy_correction_service.dart';
import 'services/edge_function_correction_service.dart';

class CorrectionResultPage extends StatefulWidget {
  const CorrectionResultPage({required this.entry, super.key});

  final RecordEntry entry;

  @override
  State<CorrectionResultPage> createState() => _CorrectionResultPageState();
}

class _CorrectionResultPageState extends State<CorrectionResultPage> {
  final _authSessionService = AuthSessionService.instance;
  final _dummyCorrectionService = const DummyCorrectionService();
  final _edgeCorrectionService = EdgeFunctionCorrectionService();
  final _correctionRepository = CorrectionRepository();
  final _vocabularyRepository = VocabularyRepository();

  Future<_CorrectionViewData>? _resultFuture;
  bool _isAddingVocabulary = false;

  @override
  void initState() {
    super.initState();
    _resultFuture = _loadSavedOrAnalyze();
  }

  Future<_CorrectionViewData> _loadSavedOrAnalyze() async {
    try {
      final saved = await _correctionRepository.fetchSavedResult(widget.entry);
      if (saved != null) {
        return _CorrectionViewData(
          result: saved,
          sourceLabel: '保存済み',
          notice: '保存済みの添削結果を表示しています。',
        );
      }
    } catch (_) {
      // 保存済み結果の取得に失敗した場合は通常解析へ進む。
    }
    return _analyzeAndSync();
  }

  Future<_CorrectionViewData> _analyzeAndSync() async {
    AiCorrectionResult result;
    var sourceLabel = 'Edge Function';
    String? notice;

    try {
      result = await _edgeCorrectionService.analyze(widget.entry);
    } catch (error) {
      result = await _dummyCorrectionService.analyze(widget.entry);
      sourceLabel = 'デモ添削';
      notice =
          'Edge Functionを利用できなかったため、デモ添削を表示しています。原因: ${_friendlyError(error)}';
    }

    try {
      await _correctionRepository.saveResult(
        entry: widget.entry,
        result: result,
      );
    } catch (error) {
      final saveError =
          'クラウド保存に失敗しました。表示中の添削結果はこの画面で確認できます。原因: ${_friendlyError(error)}';
      notice = notice == null ? saveError : '$notice\n$saveError';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('語彙メモを単語帳に追加しました。')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('単語帳への追加に失敗しました: ${_friendlyError(error)}')),
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
    if (!_authSessionService.canUsePremiumFeature) {
      return const _PremiumRequiredScaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI添削'),
        actions: [
          IconButton(
            tooltip: '再解析',
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
              message: _friendlyError(snapshot.error!),
              onRetry: _reanalyze,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final viewData = snapshot.data!;
          final result = viewData.result;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AnalysisSourceBanner(
                sourceLabel: viewData.sourceLabel,
                notice: viewData.notice,
                onRetry: viewData.sourceLabel == 'デモ添削' ? _reanalyze : null,
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
                label: const Text('語彙メモを単語帳に追加'),
                onPressed: _isAddingVocabulary
                    ? null
                    : () => _addVocabulary(result),
              ),
              const SizedBox(height: 12),
              _ResultSection(
                icon: Icons.record_voice_over_outlined,
                title: '文字起こし',
                child: Text(result.transcript),
              ),
              _ResultSection(
                icon: Icons.edit_note,
                title: '添削後の文',
                child: Text(result.correctedText),
              ),
              _ResultSection(
                icon: Icons.auto_awesome,
                title: '自然な表現',
                child: Text(result.naturalExpression),
              ),
              _ResultSection(
                icon: Icons.translate,
                title: '日本語訳',
                child: Text(result.japaneseTranslation),
              ),
              _ResultSection(
                icon: Icons.menu_book_outlined,
                title: '文法メモ',
                child: _BulletList(items: result.grammarNotes),
              ),
              _ResultSection(
                icon: Icons.style_outlined,
                title: '語彙メモ',
                child: _BulletList(items: result.vocabularyNotes),
              ),
              _ResultSection(
                icon: Icons.favorite_outline,
                title: '励ましコメント',
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
    if (message.length <= 160) {
      return message;
    }
    return '${message.substring(0, 160)}...';
  }
}

class _PremiumRequiredScaffold extends StatelessWidget {
  const _PremiumRequiredScaffold();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AI添削')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 52,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('有料機能です', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                'AI添削はPREMIUM、TESTER、ADMINアカウントで利用できます。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('戻る'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CorrectionErrorView extends StatelessWidget {
  const _CorrectionErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('AI添削を読み込めませんでした', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('もう一度試す'),
              onPressed: onRetry,
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

  final AiCorrectionResult result;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDemo = sourceLabel == 'デモ添削';

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
                  Text('解析方法: $sourceLabel', style: theme.textTheme.titleSmall),
                  if (notice != null) ...[
                    const SizedBox(height: 4),
                    Text(notice!, style: theme.textTheme.bodySmall),
                  ],
                  if (onRetry != null) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('もう一度本番解析'),
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
                  Text('AIスコア', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text('発話の伝わりやすさ、自然さ、文法のバランスを評価します。'),
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
