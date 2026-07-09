import 'package:flutter/material.dart';

import '../correction/repositories/correction_repository.dart';

class FeedbackInsightDetailPage extends StatelessWidget {
  const FeedbackInsightDetailPage({required this.insight, super.key});

  final FeedbackInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('添削ポイント詳細')),
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
                        '${insight.count}回',
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
            title: '対策メモ',
            text: insight.shortAdvice,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.record_voice_over_outlined,
            title: '次の録音で試すこと',
            text: insight.practicePrompt,
          ),
          const SizedBox(height: 12),
          _DetailCard(
            icon: Icons.repeat,
            title: '使い方',
            text: 'このポイントを意識して短く録音し、AI添削でもう一度確認すると改善の変化が見えやすくなります。',
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
