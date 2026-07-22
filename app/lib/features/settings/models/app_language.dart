enum AppLanguage {
  japanese('ja', '日本語'),
  english('en', '英語'),
  spanish('es', 'スペイン語'),
  french('fr', 'フランス語'),
  german('de', 'ドイツ語'),
  italian('it', 'イタリア語'),
  korean('ko', '韓国語'),
  simplifiedChinese('zh-Hans', '中国語');

  const AppLanguage(this.code, this.japaneseLabel);

  final String code;
  final String japaneseLabel;

  static AppLanguage? parse(String? value) {
    for (final language in values) {
      if (language.code == value || language.japaneseLabel == value) {
        return language;
      }
    }
    return null;
  }
}

const supportedBaseLocales = <AppLanguage>{
  AppLanguage.japanese,
  AppLanguage.english,
  AppLanguage.spanish,
};

const supportedLearningLanguages = <AppLanguage>{...AppLanguage.values};

List<AppLanguage> availableLearningLanguagesFor(AppLanguage baseLocale) {
  return supportedLearningLanguages
      .where((language) => language != baseLocale)
      .toList(growable: false);
}

bool isValidLanguageSelection({
  required AppLanguage baseLocale,
  required AppLanguage learningLanguage,
}) {
  return supportedBaseLocales.contains(baseLocale) &&
      supportedLearningLanguages.contains(learningLanguage) &&
      baseLocale != learningLanguage;
}

typedef InitialLanguageSelection = ({
  AppLanguage baseLocale,
  AppLanguage learningLanguage,
});

InitialLanguageSelection resolveInitialLanguageSelection({
  required String deviceLanguageTag,
  String? savedBaseLocale,
  String? savedLearningLanguage,
}) {
  final parsedBaseLocale = AppLanguage.parse(savedBaseLocale);
  final baseLocale =
      parsedBaseLocale != null &&
          supportedBaseLocales.contains(parsedBaseLocale)
      ? parsedBaseLocale
      : preferredBaseLocaleFor(deviceLanguageTag);

  final parsedLearningLanguage = AppLanguage.parse(savedLearningLanguage);
  var learningLanguage =
      parsedLearningLanguage != null &&
          supportedLearningLanguages.contains(parsedLearningLanguage)
      ? parsedLearningLanguage
      : AppLanguage.spanish;

  if (learningLanguage == baseLocale) {
    learningLanguage = availableLearningLanguagesFor(baseLocale).first;
  }

  return (baseLocale: baseLocale, learningLanguage: learningLanguage);
}

AppLanguage preferredBaseLocaleFor(String languageTag) {
  final normalizedTag = languageTag.replaceAll('_', '-').toLowerCase();
  final languageCode = normalizedTag.split('-').first;
  final locale = AppLanguage.parse(languageCode);
  if (locale != null && supportedBaseLocales.contains(locale)) {
    return locale;
  }
  return AppLanguage.english;
}
