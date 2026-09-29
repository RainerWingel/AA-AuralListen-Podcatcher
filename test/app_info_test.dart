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
}
