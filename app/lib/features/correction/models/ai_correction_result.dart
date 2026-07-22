class AiCorrectionResult {
  const AiCorrectionResult({
    required this.transcript,
    required this.correctedText,
    required this.naturalExpression,
    required this.translation,
    required this.grammarNotes,
    required this.vocabularyNotes,
    required this.score,
    required this.encouragement,
    this.learningLanguage,
    this.baseLocale,
    this.promptVersion,
  });

  static const currentPromptVersion = '2026-07-23-v1';

  final String transcript;
  final String correctedText;
  final String naturalExpression;
  final String translation;
  final List<String> grammarNotes;
  final List<String> vocabularyNotes;
  final int score;
  final String encouragement;
  final String? learningLanguage;
  final String? baseLocale;
  final String? promptVersion;

  bool matchesContext({
    required String learningLanguage,
    required String baseLocale,
    String promptVersion = currentPromptVersion,
  }) {
    return this.learningLanguage == learningLanguage &&
        this.baseLocale == baseLocale &&
        this.promptVersion == promptVersion;
  }

  factory AiCorrectionResult.fromJson(Map<String, dynamic> json) {
    return AiCorrectionResult(
      transcript: json['transcript'] as String? ?? '',
      correctedText: json['correctedText'] as String? ?? '',
      naturalExpression: json['naturalExpression'] as String? ?? '',
      translation:
          json['translation'] as String? ??
          json['japaneseTranslation'] as String? ??
          '',
      grammarNotes: _stringList(json['grammarNotes']),
      vocabularyNotes: _stringList(json['vocabularyNotes']),
      score: json['score'] as int? ?? 0,
      encouragement: json['encouragement'] as String? ?? '',
      learningLanguage:
          json['learningLanguage'] as String? ??
          json['learning_language'] as String?,
      baseLocale:
          json['baseLocale'] as String? ?? json['base_locale'] as String?,
      promptVersion:
          json['promptVersion'] as String? ?? json['prompt_version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
      'correctedText': correctedText,
      'naturalExpression': naturalExpression,
      'translation': translation,
      'grammarNotes': grammarNotes,
      'vocabularyNotes': vocabularyNotes,
      'score': score,
      'encouragement': encouragement,
      if (learningLanguage != null) 'learningLanguage': learningLanguage,
      if (baseLocale != null) 'baseLocale': baseLocale,
      if (promptVersion != null) 'promptVersion': promptVersion,
    };
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
