import 'dart:ui' show Locale;

/// UI languages of the app. The enum name is the stored value
/// (`SettingsKeys.language`) and the ARB language code – never rename.
enum AppLanguage {
  de,
  en,
  fr,
  es,
  pt,
  ru;

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

  /// Languages of 1.3.5 and older: all a user of those versions has seen.
  static const _knownBefore136 = {de, en};

  /// Value for `SettingsKeys.knownLanguages`: every language of this app.
  static String get allNames => values.map((l) => l.name).join(',');

  /// The phone's language if the app gained it since the user last saw the
  /// language list ([known]: stored names, null = updated from 1.3.5 or
  /// older) and the app runs in another one. Null = nothing to offer.
  static AppLanguage? newlyAvailable({
    required AppLanguage? current,
    required Locale? device,
    required String? known,
  }) {
    final language = fromSetting(device?.languageCode);
    if (current == null || language == null || language == current) {
      return null;
    }
    final seen = known == null
        ? _knownBefore136.map((l) => l.name).toSet()
        : known.split(',').toSet();
    return seen.contains(language.name) ? null : language;
  }

  /// Country of Apple's podcast chart ("Beliebt") for this language.
  String get chartCountry => switch (this) {
    de => 'de',
    en => 'us',
    fr => 'fr',
    es => 'es',
    pt => 'br',
    ru => 'ru',
  };
}
