class AiCorrectionResult {
  const AiCorrectionResult({
    required this.transcript,
    required this.correctedText,
    required this.naturalExpression,
    required this.japaneseTranslation,
    required this.grammarNotes,
    required this.vocabularyNotes,
    required this.score,
    required this.encouragement,
  });

  final String transcript;
  final String correctedText;
  final String naturalExpression;
  final String japaneseTranslation;
  final List<String> grammarNotes;
  final List<String> vocabularyNotes;
  final int score;
  final String encouragement;

  factory AiCorrectionResult.fromJson(Map<String, dynamic> json) {
    return AiCorrectionResult(
      transcript: json['transcript'] as String? ?? '',
      correctedText: json['correctedText'] as String? ?? '',
      naturalExpression: json['naturalExpression'] as String? ?? '',
      japaneseTranslation: json['japaneseTranslation'] as String? ?? '',
      grammarNotes: _stringList(json['grammarNotes']),
      vocabularyNotes: _stringList(json['vocabularyNotes']),
      score: json['score'] as int? ?? 0,
      encouragement: json['encouragement'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
      'correctedText': correctedText,
      'naturalExpression': naturalExpression,
      'japaneseTranslation': japaneseTranslation,
      'grammarNotes': grammarNotes,
      'vocabularyNotes': vocabularyNotes,
      'score': score,
      'encouragement': encouragement,
    };
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
