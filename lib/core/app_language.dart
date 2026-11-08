import 'dart:ui' show Locale;

/// UI languages of the app. The enum name is the stored value
/// (`SettingsKeys.language`) and the ARB language code – never rename.
enum AppLanguage {
  de,
  en,
  fr,
  es,
  pt;

  Locale get locale => Locale(name);

  /// Stored setting → language; null = not chosen yet (first start).
  static AppLanguage? fromSetting(String? value) {
    for (final language in values) {
      if (language.name == value) return language;
    }
    return null;
  }

  /// Language used before the user has chosen one: the device language if
  /// the app has it, English everywhere else.
  static AppLanguage forDevice(Locale? deviceLocale) =>
      fromSetting(deviceLocale?.languageCode) ?? en;

  /// Country of Apple's podcast chart ("Beliebt") for this language.
  String get chartCountry => switch (this) {
    de => 'de',
    en => 'us',
    fr => 'fr',
    es => 'es',
    pt => 'br',
  };
}
