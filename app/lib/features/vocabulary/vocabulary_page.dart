import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../settings/data/app_settings_store.dart';
import '../settings/models/app_language.dart';
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
    _selectedLanguage = _settingsStore.learningLanguageCode;
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
      _selectedLanguage = _settingsStore.learningLanguageCode;
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
      _selectedLanguage = _settingsStore.learningLanguageCode;
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
      exampleTranslation: edited.exampleTranslation,
    );
    _reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).wordUpdated)),
      );
    }
  }

  Future<void> _confirmAndDeleteItem(VocabularyItem item) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteWordTitle),
          content: Text(l10n.deleteWordDescription(item.word)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
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
        ).showSnackBar(SnackBar(content: Text(l10n.wordDeleted)));
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
    return item.word.toLowerCase().startsWith(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vocabularyTitle),
        actions: [
          IconButton(
            tooltip: l10n.reload,
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
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(child: Text(l10n.vocabularyEmpty)),
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
    final l10n = AppLocalizations.of(context);
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
                        tooltip: l10n.clearSearch,
                        icon: const Icon(Icons.close),
                        onPressed: onClearQuery,
                      ),
                labelText: l10n.searchVocabulary,
                hintText: l10n.vocabularySearchHint,
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
                    label: Text(filter.label(l10n)),
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
                    l10n.wordsVisible(visibleCount, totalCount),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                MenuAnchor(
                  builder: (context, controller, child) {
                    return TextButton.icon(
                      icon: const Icon(Icons.sort),
                      label: Text(sortMode.label(l10n)),
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
                        child: Text(mode.label(l10n)),
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
  all,
  pending,
  reviewed;

  String label(AppLocalizations l10n) => switch (this) {
    _VocabularyDisplayFilter.all => l10n.all,
    _VocabularyDisplayFilter.pending => l10n.reviewPending,
    _VocabularyDisplayFilter.reviewed => l10n.reviewed,
  };
}

enum _VocabularySortMode {
  word,
  createdAt,
  reviewCount;

  String label(AppLocalizations l10n) => switch (this) {
    _VocabularySortMode.word => l10n.sortAlphabetical,
    _VocabularySortMode.createdAt => l10n.sortRecentlyAdded,
    _VocabularySortMode.reviewCount => l10n.sortReviewCount,
  };
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
    final l10n = AppLocalizations.of(context);
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
                      _languageName(l10n, widget.item.learningLanguage),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  _ReviewMeta(item: widget.item),
                  PopupMenuButton<_VocabularyAction>(
                    tooltip: l10n.more,
                    onSelected: (action) {
                      switch (action) {
                        case _VocabularyAction.edit:
                          widget.onEdit();
                        case _VocabularyAction.delete:
                          widget.onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _VocabularyAction.edit,
                        child: Text(l10n.edit),
                      ),
                      PopupMenuItem(
                        value: _VocabularyAction.delete,
                        child: Text(l10n.delete),
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
          AppLocalizations.of(context).wordLabel,
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
          AppLocalizations.of(context).tapForExplanation,
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
        Text(
          AppLocalizations.of(context).explanation,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(item.meaning, style: theme.textTheme.bodyLarge),
        if (item.example != null && item.example!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).exampleSentence,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(item.example!, style: theme.textTheme.bodyMedium),
        ],
        if (item.exampleTranslation != null &&
            item.exampleTranslation!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context).exampleTranslation,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(item.exampleTranslation!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).tapToReturnToWord,
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
    final l10n = AppLocalizations.of(context);
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
                    l10n.pendingWordCount(reviewCount),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.registeredWordCount(totalCount),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.school_outlined),
              label: Text(l10n.review),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: l10n.back,
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
            child: Text(
              l10n.noWordsToReview,
              style: theme.textTheme.titleMedium,
            ),
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
              tooltip: l10n.back,
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
            const Spacer(),
            Text(
              l10n.reviewProgress(index + 1, items.length),
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
                        _languageName(l10n, item.learningLanguage),
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
                            Text(
                              l10n.meaning,
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.meaning,
                              style: theme.textTheme.bodyLarge,
                            ),
                            if (item.example != null &&
                                item.example!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.exampleSentence,
                                style: theme.textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.example!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                            if (item.exampleTranslation != null &&
                                item.exampleTranslation!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                l10n.exampleTranslation,
                                style: theme.textTheme.labelLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.exampleTranslation!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        )
                      : Center(
                          key: const ValueKey('hidden'),
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.visibility_outlined),
                            label: Text(l10n.showMeaning),
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
                label: Text(l10n.next),
                onPressed: onNext,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(l10n.remembered),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lastReviewedAt = item.lastReviewedAt;
    final label = lastReviewedAt == null
        ? l10n.reviewCountOnly(item.reviewCount)
        : l10n.reviewCountWithDate(
            item.reviewCount,
            _formatDate(context, lastReviewedAt),
          );
    return Text(label, style: theme.textTheme.labelSmall);
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    return DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(dateTime.toLocal());
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
  late final TextEditingController _exampleTranslationController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.item.word);
    _meaningController = TextEditingController(text: widget.item.meaning);
    _exampleController = TextEditingController(text: widget.item.example ?? '');
    _exampleTranslationController = TextEditingController(
      text: widget.item.exampleTranslation ?? '',
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editWordTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              decoration: InputDecoration(labelText: l10n.wordLabel),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _meaningController,
              decoration: InputDecoration(labelText: l10n.meaningExplanation),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleController,
              decoration: InputDecoration(labelText: l10n.exampleSentence),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleTranslationController,
              decoration: InputDecoration(labelText: l10n.exampleTranslation),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }

  void _submit() {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wordAndMeaningRequired),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _VocabularyEditData(
        word: word,
        meaning: meaning,
        example: _exampleController.text.trim(),
        exampleTranslation: _exampleTranslationController.text.trim(),
      ),
    );
  }
}

class _VocabularyEditData {
  const _VocabularyEditData({
    required this.word,
    required this.meaning,
    required this.example,
    required this.exampleTranslation,
  });

  final String word;
  final String meaning;
  final String example;
  final String exampleTranslation;
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
    final l10n = AppLocalizations.of(context);
    final languages = [null, ...AppLanguage.values.map((value) => value.code)];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final language in languages)
          ChoiceChip(
            label: Text(
              language == null ? l10n.all : _languageName(l10n, language),
            ),
            selected: selectedLanguage == language,
            onSelected: (_) => onSelected(language),
          ),
      ],
    );
  }
}

String _languageName(AppLocalizations l10n, String value) {
  final code = AppLanguage.parse(value)?.code ?? value;
  return l10n.languageName(code == 'zh-Hans' ? 'zhHans' : code);
}
