import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../correction/repositories/correction_repository.dart';

class FeedbackInsightDetailPage extends StatelessWidget {
  const FeedbackInsightDetailPage({required this.insight, super.key});

  final FeedbackInsight insight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(label: Text(insight.categoryLabel)),
                      const Spacer(),
                      Text(
                        l10n.recordingCount(insight.count),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    insight.text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.lightbulb_outline,
            title: l10n.strategyNotes,
            text: insight.categoryLabel == '文法'
                ? l10n.grammarAdvice
                : l10n.vocabularyAdvice,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.record_voice_over_outlined,
            title: l10n.tryNextRecording,
            text: insight.categoryLabel == '文法'
                ? l10n.grammarPracticePrompt
                : l10n.vocabularyPracticePrompt,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.repeat,
            title: l10n.howToUse,
            text: l10n.feedbackUsageDescription,
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(text, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
