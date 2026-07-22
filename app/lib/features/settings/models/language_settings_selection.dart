import 'app_language.dart';

class LanguageSettingsSelection {
  const LanguageSettingsSelection({
    required this.baseLocale,
    required this.learningLanguage,
  });

  final AppLanguage baseLocale;
  final AppLanguage learningLanguage;

  static LanguageSettingsSelection? fromCloudRow(Map<String, dynamic>? row) {
    if (row == null) {
      return null;
    }
    final baseLocale = AppLanguage.parse(row['base_locale'] as String?);
    final learningLanguage = AppLanguage.parse(
      row['learning_language'] as String?,
    );
    if (baseLocale == null ||
        learningLanguage == null ||
        !isValidLanguageSelection(
          baseLocale: baseLocale,
          learningLanguage: learningLanguage,
        )) {
      return null;
    }
    return LanguageSettingsSelection(
      baseLocale: baseLocale,
      learningLanguage: learningLanguage,
    );
  }

  Map<String, String> toCloudValues() => {
    'base_locale': baseLocale.code,
    'learning_language': learningLanguage.code,
  };
}
