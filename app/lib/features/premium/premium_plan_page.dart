import 'package:flutter/material.dart';

class PremiumPlanPage extends StatelessWidget {
  const PremiumPlanPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const PremiumPlanPage());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.asset(
            'assets/images/talkLog_premium.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text('Premiumで学習を続ける', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'AI添削と音声保存の制限を気にせず、自分の声の成長ログを積み上げられます。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          const _PlanComparisonTable(),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('月980円で登録'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('サブスク登録はGoogle Playの商品設定後に有効化します。'),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '解約後も、現在の更新日前日まではPremium機能を利用できる設計で接続します。',
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
    final rows = const [
      _PlanRow('AI添削', '1日5回', '無制限'),
      _PlanRow('AI翻訳', '制限あり', '無制限'),
      _PlanRow('音声保存', '200MB', '無制限'),
      _PlanRow('添削履歴', '利用可', '利用可'),
      _PlanRow('単語ランキング', '利用可', '利用可'),
      _PlanRow('広告', 'リワード広告あり', 'なし'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _ComparisonRow(
            cells: const ['項目', 'Free', 'Premium'],
            isHeader: true,
            textStyle: theme.textTheme.labelLarge,
          ),
          for (final row in rows)
            _ComparisonRow(
              cells: [row.feature, row.free, row.premium],
              textStyle: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.cells,
    required this.textStyle,
    this.isHeader = false,
  });

  final List<String> cells;
  final TextStyle? textStyle;
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
                    style: textStyle?.copyWith(
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

class _PlanRow {
  const _PlanRow(this.feature, this.free, this.premium);

  final String feature;
  final String free;
  final String premium;
}
