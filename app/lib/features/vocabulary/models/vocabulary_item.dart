class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.recordingId,
    required this.language,
    required this.word,
    required this.meaning,
    required this.example,
    required this.isReviewed,
    required this.reviewCount,
    required this.lastReviewedAt,
    required this.createdAt,
  });

  final String id;
  final String recordingId;
  final String language;
  final String word;
  final String meaning;
  final String? example;
  final bool isReviewed;
  final int reviewCount;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as String,
      recordingId: json['recording_id'] as String,
      language: json['language'] as String? ?? 'スペイン語',
      word: json['word'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      example: json['example'] as String?,
      isReviewed: json['is_reviewed'] as bool? ?? false,
      reviewCount: json['review_count'] as int? ?? 0,
      lastReviewedAt: _optionalDateTime(json['last_reviewed_at']),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  static DateTime? _optionalDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value).toLocal();
  }
}
