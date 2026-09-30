/// App version as in pubspec.yaml – update both together on a release
/// (docs/build-and-release.md → GitHub-Release).
const appVersion = '1.2.1';

/// Name shown to people (store, settings); the launcher uses "AuralListen".
const appName = 'AA-AuralListen Podcatcher';

/// Developer as shown on the info page and in the privacy policy.
const appDeveloper = 'Artem A.';

/// German privacy policy (legally binding); [privacyPolicyUrlEn] is the
/// English translation, opened when the app runs in English.
const privacyPolicyUrl =
    'https://rainerwingel.github.io/AA-AuralListen-Podcatcher/datenschutz/';
const privacyPolicyUrlEn =
    'https://rainerwingel.github.io/AA-AuralListen-Podcatcher/privacy/';
const sourceCodeUrl =
    'https://github.com/RainerWingel/AA-AuralListen-Podcatcher';

/// User-Agent for feeds, directories, downloads and streaming.
const appUserAgent =
    'AA-AuralListen/$appVersion (+https://github.com/RainerWingel/AA-AuralListen-Podcatcher)';
