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

  String get languageCode => _stableLanguageCode(language);

  factory RecordEntry.fromJson(Map<String, dynamic> json) {
    return RecordEntry(
      id: json['id'] as String,
      createdAt: parseStoredDateTime(json['createdAt'] as String),
      duration: Duration(milliseconds: json['durationMs'] as int),
      audioPath: json['audioPath'] as String,
      language: json['language'] as String? ?? 'スペイン語',
    );
  }

  static DateTime parseStoredDateTime(String value) {
    final hasTimeZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
    final parsed = DateTime.parse(value);
    if (parsed.isUtc || hasTimeZone) {
      return parsed.toLocal();
    }

    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).toLocal();
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

String _stableLanguageCode(String value) {
  const legacyCodes = {
    '日本語': 'ja',
    '英語': 'en',
    'スペイン語': 'es',
    'フランス語': 'fr',
    'ドイツ語': 'de',
    'イタリア語': 'it',
    '韓国語': 'ko',
    '中国語': 'zh-Hans',
  };
  return legacyCodes[value] ?? value;
}
