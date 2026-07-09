class WordUsage {
  const WordUsage({
    required this.word,
    required this.count,
    required this.language,
    required this.alternativeWords,
    required this.advice,
  });

  final String word;
  final int count;
  final String language;
  final List<String> alternativeWords;
  final String advice;

  factory WordUsage.fromJson(Map<String, dynamic> json) {
    return WordUsage(
      word: json['word'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      language: json['language'] as String? ?? 'スペイン語',
      alternativeWords: _stringList(json['alternative_words']),
      advice: json['advice'] as String? ?? '',
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }
}
