/// App version as in pubspec.yaml – update both together on a release
/// (docs/build-and-release.md → GitHub-Release).
const appVersion = '1.2.0';

/// Name shown to people (store, settings); the launcher uses "AuralListen".
const appName = 'AA-AuralListen Podcatcher';

/// Developer as shown on the info page and in the privacy policy.
const appDeveloper = 'Artem A.';

/// Voluntary tip via PayPal (info page). Google Play generally does not
/// allow external payment links for tips – set to false for a Play Store
/// build (docs/build-and-release.md).
const showTipLink = true;
const tipUrl = 'https://paypal.me/Yama83';

const privacyPolicyUrl =
    'https://rainerwingel.github.io/AA-AuralListen-Podcatcher/datenschutz/';
const sourceCodeUrl =
    'https://github.com/RainerWingel/AA-AuralListen-Podcatcher';

/// User-Agent for feeds, directories, downloads and streaming.
const appUserAgent =
    'AA-AuralListen/$appVersion (+https://github.com/RainerWingel/AA-AuralListen-Podcatcher)';
