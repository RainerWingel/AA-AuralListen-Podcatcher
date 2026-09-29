import 'dart:ui' show Locale;

/// UI languages of the app. The enum name is the stored value
/// (`SettingsKeys.language`) and the ARB language code – never rename.
enum AppLanguage {
  de,
  en;

  Locale get locale => Locale(name);

  /// Stored setting → language; null = not chosen yet (first start).
  static AppLanguage? fromSetting(String? value) {
    for (final language in values) {
      if (language.name == value) return language;
    }
    return null;
  }

  /// Language used before the user has chosen one: German on German devices,
  /// English everywhere else.
  static AppLanguage forDevice(Locale? deviceLocale) =>
      deviceLocale?.languageCode == 'de' ? de : en;
}
