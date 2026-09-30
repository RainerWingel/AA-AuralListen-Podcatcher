import 'dart:io';

import 'package:aapodcastguru/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appVersion matches pubspec.yaml (update both on a release)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([0-9.]+)\+',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(appVersion, version);
    expect(appUserAgent, startsWith('AA-AuralListen/$version '));
  });

  test('privacy policy names the same developer as the info page', () {
    final policy = File('docs/datenschutz.md').readAsStringSync();
    expect(policy, contains('**Entwickler:** $appDeveloper'));
    final english = File('docs/privacy.md').readAsStringSync();
    expect(english, contains('**Developer:** $appDeveloper'));
  });

  test('both privacy policy versions exist, link each other and match', () {
    final german = File('docs/datenschutz.md').readAsStringSync();
    final english = File('docs/privacy.md').readAsStringSync();
    expect(german, contains('](../privacy/)'));
    expect(english, contains('](../datenschutz/)'));
    // Same sections in both (a change in one needs the other too).
    int sections(String text) =>
        RegExp(r'^## ', multiLine: true).allMatches(text).length;
    expect(sections(english), sections(german));
    final published = File('docs/_config.yml').readAsStringSync();
    expect(published, contains('privacy.md'));
    expect(privacyPolicyUrlEn, endsWith('/privacy/'));
  });
}
