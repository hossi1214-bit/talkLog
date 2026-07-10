import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/core/utils/japan_time.dart';

void main() {
  test('converts UTC timestamps to Japan time', () {
    final japanTime = JapanTime.from(DateTime.utc(2026, 7, 9, 23, 58));

    expect(japanTime.year, 2026);
    expect(japanTime.month, 7);
    expect(japanTime.day, 10);
    expect(japanTime.hour, 8);
    expect(japanTime.minute, 58);
  });

  test('returns Japan date only', () {
    final date = JapanTime.dateOnly(DateTime.utc(2026, 7, 9, 23, 58));

    expect(date, DateTime(2026, 7, 10));
  });
}
