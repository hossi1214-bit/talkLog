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

  late Future<List<VocabularyItem>> _itemsFuture;
  bool _showReviewed = true;
  bool _isReviewMode = false;
  bool _isMeaningVisible = false;
  int _reviewIndex = 0;
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
    _settingsStore.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await _settingsStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLanguage = _settingsStore.learningLanguage;
      _itemsFuture = _repository.fetchAll(language: _selectedLanguage);
      _resetReviewState();
    });
  }

  void _handleSettingsChanged() {
    if (!_settingsStore.isLoaded || _selectedLanguage == null) {
      return;
    }
    setState(() {
      _selectedLanguage = _settingsStore.learningLanguage;
      _itemsFuture = _repository.fetchAll(language: _selectedLanguage);
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

          final allItems = snapshot.data!;
          final visibleItems = allItems
              .where((item) => _showReviewed || !item.isReviewed)
              .toList(growable: false);
          final reviewItems = allItems
              .where((item) => !item.isReviewed)
              .toList(growable: false);

          if (_isReviewMode) {
            return _ReviewModeView(
              items: reviewItems,
              index: _reviewIndex.clamp(0, reviewItems.length - 1),
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
              _VocabularySummary(
                totalCount: allItems.length,
                reviewCount: reviewItems.length,
                onStartReview: reviewItems.isEmpty ? null : _startReview,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _showReviewed,
                title: const Text('復習済みも表示'),
                onChanged: (value) {
                  setState(() {
                    _showReviewed = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              if (visibleItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('単語帳はまだ空です。添削結果の語彙メモから追加できます。')),
                )
              else
                for (final item in visibleItems)
                  Card(
                    child: ListTile(
                      leading: Checkbox(
                        value: item.isReviewed,
                        onChanged: (value) =>
                            _setReviewed(item, value ?? false),
                      ),
                      title: Text(item.word),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.meaning),
                          const SizedBox(height: 4),
                          Text(
                            item.language,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          if (item.example != null && item.example!.isNotEmpty)
                            Text(item.example!),
                        ],
                      ),
                      trailing: PopupMenuButton<_VocabularyAction>(
                        tooltip: 'その他',
                        onSelected: (action) {
                          switch (action) {
                            case _VocabularyAction.edit:
                              _editItem(item);
                            case _VocabularyAction.delete:
                              _confirmAndDeleteItem(item);
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
                    ),
                  ),
            ],
          );
        },
      ),
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
              decoration: const InputDecoration(labelText: '意味'),
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
