import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/recording/models/record_entry.dart';

void main() {
  test('parses timestamp without timezone as UTC', () {
    final parsed = RecordEntry.parseStoredDateTime('2026-07-09T23:58:00');

    expect(parsed.toUtc(), DateTime.utc(2026, 7, 9, 23, 58));
  });

  test('parses timestamp with timezone without double shifting', () {
    final parsed = RecordEntry.parseStoredDateTime('2026-07-09T23:58:00Z');

    expect(parsed.toUtc(), DateTime.utc(2026, 7, 9, 23, 58));
  });

  test('normalizes a legacy language label to a stable code', () {
    final entry = RecordEntry(
      id: 'legacy-language',
      createdAt: DateTime.utc(2026, 7, 23),
      duration: const Duration(seconds: 10),
      audioPath: 'recording.m4a',
      language: 'スペイン語',
    );

    expect(entry.languageCode, 'es');
  });
}
