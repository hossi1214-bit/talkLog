import 'package:flutter/material.dart';

import '../settings/data/app_settings_store.dart';
import 'models/vocabulary_item.dart';
import 'repositories/vocabulary_repository.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final _repository = VocabularyRepository();
  final _settingsStore = AppSettingsStore.instance;
  final _searchController = TextEditingController();

  late Future<List<VocabularyItem>> _itemsFuture;
  _VocabularyDisplayFilter _displayFilter = _VocabularyDisplayFilter.all;
  _VocabularySortMode _sortMode = _VocabularySortMode.word;
  String _query = '';
  bool _isReviewMode = false;
  bool _isMeaningVisible = false;
  int _reviewIndex = 0;
  int _cardResetKey = 0;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _settingsStore.learningLanguage;
    _itemsFuture = _repository.fetchAll(language: _selectedLanguage);
    _settingsStore.addListener(_handleSettingsChanged);
    _loadSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _settingsStore.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await _settingsStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      final previousLanguage = _selectedLanguage;
      _selectedLanguage = _settingsStore.learningLanguage;
      _itemsFuture = _repository.fetchAll(language: _selectedLanguage);
      if (previousLanguage != _selectedLanguage) {
        _cardResetKey++;
      }
      _resetReviewState();
    });
  }

  void _handleSettingsChanged() {
    if (!_settingsStore.isLoaded || _selectedLanguage == null) {
      return;
    }
    setState(() {
      final previousLanguage = _selectedLanguage;
      _selectedLanguage = _settingsStore.learningLanguage;
      _itemsFuture = _repository.fetchAll(language: _selectedLanguage);
      if (previousLanguage != _selectedLanguage) {
        _cardResetKey++;
      }
      _resetReviewState();
    });
  }

  void _reload() {
    setState(() {
      _itemsFuture = _repository.fetchAll(language: _selectedLanguage);
      _resetReviewState();
    });
  }

  void _selectLanguage(String? language) {
    if (_selectedLanguage == language) {
      return;
    }
    setState(() {
      _selectedLanguage = language;
      _itemsFuture = _repository.fetchAll(language: language);
      _cardResetKey++;
      _resetReviewState();
    });
  }

  Future<void> _setReviewed(VocabularyItem item, bool value) async {
    await _repository.setReviewed(item, value);
    _reload();
  }

  Future<void> _editItem(VocabularyItem item) async {
    final edited = await showDialog<_VocabularyEditData>(
      context: context,
      builder: (context) => _VocabularyEditDialog(item: item),
    );
    if (edited == null) {
      return;
    }

    await _repository.updateItem(
      item: item,
      word: edited.word,
      meaning: edited.meaning,
      example: edited.example,
    );
    _reload();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('単語を更新しました。')));
    }
  }

  Future<void> _confirmAndDeleteItem(VocabularyItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('単語を削除しますか？'),
          content: Text('「${item.word}」を単語帳から削除します。この操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _repository.deleteItem(item);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('単語を削除しました。')));
      }
    }
  }

  Future<void> _markCurrentReviewed(VocabularyItem item) async {
    await _repository.setReviewed(item, true);
    _reload();
  }

  void _startReview() {
    setState(() {
      _isReviewMode = true;
      _isMeaningVisible = false;
      _reviewIndex = 0;
    });
  }

  void _closeReview() {
    setState(() {
      _resetReviewState();
    });
  }

  void _showMeaning() {
    setState(() {
      _isMeaningVisible = true;
    });
  }

  void _nextReview(int itemCount) {
    if (itemCount == 0) {
      return;
    }
    setState(() {
      _reviewIndex = (_reviewIndex + 1) % itemCount;
      _isMeaningVisible = false;
    });
  }

  void _resetReviewState() {
    _isReviewMode = false;
    _isMeaningVisible = false;
    _reviewIndex = 0;
  }

  List<VocabularyItem> _sortItems(Iterable<VocabularyItem> items) {
    final sorted = items.toList(growable: false);
    sorted.sort((a, b) {
      final compare = switch (_sortMode) {
        _VocabularySortMode.word => a.word.toLowerCase().compareTo(
          b.word.toLowerCase(),
        ),
        _VocabularySortMode.createdAt => b.createdAt.compareTo(a.createdAt),
        _VocabularySortMode.reviewCount => b.reviewCount.compareTo(
          a.reviewCount,
        ),
      };
      if (compare != 0) {
        return compare;
      }
      return a.word.toLowerCase().compareTo(b.word.toLowerCase());
    });
    return sorted;
  }

  bool _matchesDisplayFilter(VocabularyItem item) {
    return switch (_displayFilter) {
      _VocabularyDisplayFilter.all => true,
      _VocabularyDisplayFilter.pending => !item.isReviewed,
      _VocabularyDisplayFilter.reviewed => item.isReviewed,
    };
  }

  bool _matchesQuery(VocabularyItem item) {
    final query = _query;
    if (query.isEmpty) {
      return true;
    }
    final target = [
      item.word,
      item.meaning,
      item.example ?? '',
      item.language,
    ].join(' ').toLowerCase();
    return target.contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語帳'),
        actions: [
          IconButton(
            tooltip: '再読み込み',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<VocabularyItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allItems = _sortItems(snapshot.data!);
          final visibleItems = _sortItems(
            allItems.where(
              (item) => _matchesDisplayFilter(item) && _matchesQuery(item),
            ),
          );
          final reviewItems = _sortItems(
            allItems.where((item) => !item.isReviewed),
          );

          if (_isReviewMode) {
            return _ReviewModeView(
              items: reviewItems,
              index: reviewItems.isEmpty
                  ? 0
                  : _reviewIndex.clamp(0, reviewItems.length - 1),
              isMeaningVisible: _isMeaningVisible,
              onClose: _closeReview,
              onShowMeaning: _showMeaning,
              onNext: () => _nextReview(reviewItems.length),
              onReviewed: reviewItems.isEmpty
                  ? null
                  : () => _markCurrentReviewed(
                      reviewItems[_reviewIndex.clamp(
                        0,
                        reviewItems.length - 1,
                      )],
                    ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _LanguageFilter(
                selectedLanguage: _selectedLanguage,
                onSelected: _selectLanguage,
              ),
              const SizedBox(height: 8),
              _VocabularySearchAndSort(
                controller: _searchController,
                query: _query,
                displayFilter: _displayFilter,
                sortMode: _sortMode,
                visibleCount: visibleItems.length,
                totalCount: allItems.length,
                onQueryChanged: (value) {
                  setState(() {
                    _query = value.trim().toLowerCase();
                  });
                },
                onClearQuery: () {
                  setState(() {
                    _query = '';
                    _searchController.clear();
                  });
                },
                onDisplayFilterChanged: (filter) {
                  setState(() {
                    _displayFilter = filter;
                  });
                },
                onSortModeChanged: (sortMode) {
                  setState(() {
                    _sortMode = sortMode;
                  });
                },
              ),
              const SizedBox(height: 8),
              _VocabularySummary(
                totalCount: allItems.length,
                reviewCount: reviewItems.length,
                onStartReview: reviewItems.isEmpty ? null : _startReview,
              ),
              const SizedBox(height: 8),
              if (visibleItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('単語帳はまだ空です。添削結果の語彙メモから追加できます。')),
                )
              else
                for (final item in visibleItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VocabularyFlipCard(
                      key: ValueKey(
                        '$_cardResetKey-${_selectedLanguage ?? 'all'}-${item.id}',
                      ),
                      item: item,
                      onReviewedChanged: (value) =>
                          _setReviewed(item, value ?? false),
                      onEdit: () => _editItem(item),
                      onDelete: () => _confirmAndDeleteItem(item),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _VocabularySearchAndSort extends StatelessWidget {
  const _VocabularySearchAndSort({
    required this.controller,
    required this.query,
    required this.displayFilter,
    required this.sortMode,
    required this.visibleCount,
    required this.totalCount,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onDisplayFilterChanged,
    required this.onSortModeChanged,
  });

  final TextEditingController controller;
  final String query;
  final _VocabularyDisplayFilter displayFilter;
  final _VocabularySortMode sortMode;
  final int visibleCount;
  final int totalCount;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<_VocabularyDisplayFilter> onDisplayFilterChanged;
  final ValueChanged<_VocabularySortMode> onSortModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '検索をクリア',
                        icon: const Icon(Icons.close),
                        onPressed: onClearQuery,
                      ),
                labelText: '単語帳を検索',
                hintText: '単語・意味・例文で検索',
                border: const OutlineInputBorder(),
              ),
              onChanged: onQueryChanged,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in _VocabularyDisplayFilter.values)
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: displayFilter == filter,
                    onSelected: (_) => onDisplayFilterChanged(filter),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$visibleCount / $totalCount 語を表示',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                MenuAnchor(
                  builder: (context, controller, child) {
                    return TextButton.icon(
                      icon: const Icon(Icons.sort),
                      label: Text(sortMode.label),
                      onPressed: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                    );
                  },
                  menuChildren: [
                    for (final mode in _VocabularySortMode.values)
                      MenuItemButton(
                        leadingIcon: sortMode == mode
                            ? const Icon(Icons.check)
                            : const SizedBox(width: 24),
                        onPressed: () => onSortModeChanged(mode),
                        child: Text(mode.label),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _VocabularyDisplayFilter {
  all('すべて'),
  pending('復習待ち'),
  reviewed('復習済み');

  const _VocabularyDisplayFilter(this.label);

  final String label;
}

enum _VocabularySortMode {
  word('アルファベット順'),
  createdAt('最近追加'),
  reviewCount('復習回数');

  const _VocabularySortMode(this.label);

  final String label;
}

class _VocabularyFlipCard extends StatefulWidget {
  const _VocabularyFlipCard({
    super.key,
    required this.item,
    required this.onReviewedChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final VocabularyItem item;
  final ValueChanged<bool?> onReviewedChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_VocabularyFlipCard> createState() => _VocabularyFlipCardState();
}

class _VocabularyFlipCardState extends State<_VocabularyFlipCard> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _showBack = !_showBack;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: widget.item.isReviewed,
                    onChanged: widget.onReviewedChanged,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.item.language,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  _ReviewMeta(item: widget.item),
                  PopupMenuButton<_VocabularyAction>(
                    tooltip: 'その他',
                    onSelected: (action) {
                      switch (action) {
                        case _VocabularyAction.edit:
                          widget.onEdit();
                        case _VocabularyAction.delete:
                          widget.onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _VocabularyAction.edit,
                        child: Text('編集'),
                      ),
                      PopupMenuItem(
                        value: _VocabularyAction.delete,
                        child: Text('削除'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SizeTransition(sizeFactor: animation, child: child),
                ),
                child: _showBack
                    ? _VocabularyCardBack(
                        key: ValueKey('${widget.item.id}-back'),
                        item: widget.item,
                      )
                    : _VocabularyCardFront(
                        key: ValueKey('${widget.item.id}-front'),
                        item: widget.item,
                        accentColor: colorScheme.primary,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VocabularyCardFront extends StatelessWidget {
  const _VocabularyCardFront({
    super.key,
    required this.item,
    required this.accentColor,
  });

  final VocabularyItem item;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '単語',
          style: theme.textTheme.labelLarge?.copyWith(color: accentColor),
        ),
        const SizedBox(height: 10),
        Text(
          item.word,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'タップで解説を表示',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _VocabularyCardBack extends StatelessWidget {
  const _VocabularyCardBack({super.key, required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('解説', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(item.meaning, style: theme.textTheme.bodyLarge),
        if (item.example != null && item.example!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('例文', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(item.example!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 12),
        Text(
          'タップで単語に戻る',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _VocabularySummary extends StatelessWidget {
  const _VocabularySummary({
    required this.totalCount,
    required this.reviewCount,
    required this.onStartReview,
  });

  final int totalCount;
  final int reviewCount;
  final VoidCallback? onStartReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.style_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '復習待ち $reviewCount語',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('登録済み $totalCount語', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.school_outlined),
              label: const Text('復習'),
              onPressed: onStartReview,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewModeView extends StatelessWidget {
  const _ReviewModeView({
    required this.items,
    required this.index,
    required this.isMeaningVisible,
    required this.onClose,
    required this.onShowMeaning,
    required this.onNext,
    required this.onReviewed,
  });

  final List<VocabularyItem> items;
  final int index;
  final bool isMeaningVisible;
  final VoidCallback onClose;
  final VoidCallback onShowMeaning;
  final VoidCallback onNext;
  final VoidCallback? onReviewed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: '戻る',
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
          ),
          const SizedBox(height: 80),
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('復習待ちの単語はありません。', style: theme.textTheme.titleMedium),
          ),
        ],
      );
    }

    final item = items[index];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: '戻る',
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
            const Spacer(),
            Text(
              '${index + 1} / ${items.length}',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.language,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    _ReviewMeta(item: item),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    item.word,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isMeaningVisible
                      ? Column(
                          key: const ValueKey('meaning'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('意味', style: theme.textTheme.labelLarge),
                            const SizedBox(height: 8),
                            Text(
                              item.meaning,
                              style: theme.textTheme.bodyLarge,
                            ),
                            if (item.example != null &&
                                item.example!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text('例文', style: theme.textTheme.labelLarge),
                              const SizedBox(height: 8),
                              Text(
                                item.example!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        )
                      : Center(
                          key: const ValueKey('hidden'),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('意味を見る'),
                            onPressed: onShowMeaning,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('次へ'),
                onPressed: onNext,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('覚えた'),
                onPressed: onReviewed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewMeta extends StatelessWidget {
  const _ReviewMeta({required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastReviewedAt = item.lastReviewedAt;
    final label = lastReviewedAt == null
        ? '復習 ${item.reviewCount}回'
        : '復習 ${item.reviewCount}回 / 最終 ${_formatDate(lastReviewedAt)}';
    return Text(label, style: theme.textTheme.labelSmall);
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$month/$day';
  }
}

class _VocabularyEditDialog extends StatefulWidget {
  const _VocabularyEditDialog({required this.item});

  final VocabularyItem item;

  @override
  State<_VocabularyEditDialog> createState() => _VocabularyEditDialogState();
}

class _VocabularyEditDialogState extends State<_VocabularyEditDialog> {
  late final TextEditingController _wordController;
  late final TextEditingController _meaningController;
  late final TextEditingController _exampleController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.item.word);
    _meaningController = TextEditingController(text: widget.item.meaning);
    _exampleController = TextEditingController(text: widget.item.example ?? '');
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('単語を編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(labelText: '単語'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _meaningController,
              decoration: const InputDecoration(labelText: '意味・解説'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleController,
              decoration: const InputDecoration(labelText: '例文'),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }

  void _submit() {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('単語と意味を入力してください。')));
      return;
    }

    Navigator.of(context).pop(
      _VocabularyEditData(
        word: word,
        meaning: meaning,
        example: _exampleController.text.trim(),
      ),
    );
  }
}

class _VocabularyEditData {
  const _VocabularyEditData({
    required this.word,
    required this.meaning,
    required this.example,
  });

  final String word;
  final String meaning;
  final String example;
}

enum _VocabularyAction { edit, delete }

class _LanguageFilter extends StatelessWidget {
  const _LanguageFilter({
    required this.selectedLanguage,
    required this.onSelected,
  });

  final String? selectedLanguage;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final languages = [null, ...AppSettingsStore.supportedLanguages];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final language in languages)
          ChoiceChip(
            label: Text(language ?? 'すべて'),
            selected: selectedLanguage == language,
            onSelected: (_) => onSelected(language),
          ),
      ],
    );
  }
}
