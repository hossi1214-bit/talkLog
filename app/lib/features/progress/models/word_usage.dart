class WordUsage {
  const WordUsage({
    required this.word,
    required this.count,
    required this.language,
    required this.alternativeWords,
    required this.advice,
    this.adviceByLocale = const {},
  });

  final String word;
  final int count;
  final String language;
  final List<String> alternativeWords;
  final String advice;
  final Map<String, String> adviceByLocale;

  String localizedAdvice(String baseLocale, String fallback) {
    final localized = adviceByLocale[baseLocale]?.trim();
    if (localized != null && localized.isNotEmpty) {
      return localized;
    }
    if (baseLocale == 'ja' && advice.trim().isNotEmpty) {
      return advice;
    }
    return fallback;
  }

  factory WordUsage.fromJson(Map<String, dynamic> json) {
    return WordUsage(
      word: json['word'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      language: json['language'] as String? ?? 'スペイン語',
      alternativeWords: _stringList(json['alternative_words']),
      advice: json['advice'] as String? ?? '',
      adviceByLocale: json['advice_i18n'] is Map
          ? Map<String, String>.from(
              (json['advice_i18n'] as Map).map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
            )
          : const {},
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }
}
