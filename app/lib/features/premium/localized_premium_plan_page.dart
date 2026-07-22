import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LocalizedPremiumPlanPage extends StatelessWidget {
  const LocalizedPremiumPlanPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const LocalizedPremiumPlanPage());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.premiumTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.asset(
            'assets/images/talkLog_premium.png',
            width: 72,
            height: 72,
          ),
          const SizedBox(height: 12),
          Text(l10n.premiumHeadline, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l10n.premiumDescription),
          const SizedBox(height: 20),
          const _PlanComparisonTable(),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(l10n.premiumSubscribePrice),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.premiumPurchaseUnavailable)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.premiumCancellationNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PlanComparisonTable extends StatelessWidget {
  const _PlanComparisonTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final rows = [
      [l10n.premiumAiCorrection, l10n.premiumFivePerDay, l10n.premiumUnlimited],
      [l10n.premiumAiTranslation, l10n.premiumLimited, l10n.premiumUnlimited],
      [l10n.premiumAudioStorage, '200MB', l10n.premiumUnlimited],
      [
        l10n.premiumCorrectionHistory,
        l10n.premiumAvailable,
        l10n.premiumAvailable,
      ],
      [l10n.premiumWordRanking, l10n.premiumAvailable, l10n.premiumAvailable],
      [l10n.premiumAds, l10n.premiumRewardAds, l10n.premiumNone],
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _ComparisonRow(
            cells: [l10n.premiumItem, 'Free', 'Premium'],
            isHeader: true,
          ),
          for (final row in rows) _ComparisonRow(cells: row),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.cells, this.isHeader = false});

  final List<String> cells;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isHeader ? theme.colorScheme.surfaceContainerHighest : null,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var index = 0; index < cells.length; index++)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: index == cells.length - 1
                        ? null
                        : Border(
                            right: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                  ),
                  child: Text(
                    cells[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isHeader ? FontWeight.w700 : null,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
