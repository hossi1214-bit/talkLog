class RecordEntry {
  const RecordEntry({
    required this.id,
    required this.createdAt,
    required this.duration,
    required this.audioPath,
    this.language = 'スペイン語',
  });

  final String id;
  final DateTime createdAt;
  final Duration duration;
  final String audioPath;
  final String language;

  factory RecordEntry.fromJson(Map<String, dynamic> json) {
    return RecordEntry(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      duration: Duration(milliseconds: json['durationMs'] as int),
      audioPath: json['audioPath'] as String,
      language: json['language'] as String? ?? 'スペイン語',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'audioPath': audioPath,
      'language': language,
    };
  }
}
