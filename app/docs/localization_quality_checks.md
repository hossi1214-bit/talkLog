# Localization quality checks

Run the automated ARB key check with the rest of the test suite:

```powershell
flutter test
```

`test/localization_integrity_test.dart` fails when Japanese or Spanish is
missing a message key present in the English source ARB, or contains a key that
does not exist in English.

Before merging UI changes, search active feature widgets for literal strings:

```powershell
rg -n "Text\(|Tooltip\(|SnackBar\(|labelText:|hintText:" lib/features -g "*.dart"
```

Review string literals passed directly to those widgets. User-facing copy must
come from `AppLocalizations`. The following literals may remain inline:

- the product name `TalkLog`;
- punctuation or symbols such as `・`;
- values supplied by user data, AI results, or formatted numbers;
- internal identifiers, error codes, compatibility values, and test/dummy data
  that are not rendered directly as interface copy.

When adding a message, add it to `app_en.arb`, `app_ja.arb`, and `app_es.arb`,
then run `flutter gen-l10n`, `dart format .`, `flutter analyze`, and
`flutter test`.
