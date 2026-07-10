class JapanTime {
  const JapanTime._();

  static const offset = Duration(hours: 9);

  static DateTime from(DateTime dateTime) {
    return dateTime.toUtc().add(offset);
  }

  static DateTime now() {
    return from(DateTime.now());
  }

  static DateTime today() {
    final japanTime = now();
    return DateTime(japanTime.year, japanTime.month, japanTime.day);
  }

  static DateTime dateOnly(DateTime dateTime) {
    final japanTime = from(dateTime);
    return DateTime(japanTime.year, japanTime.month, japanTime.day);
  }
}
