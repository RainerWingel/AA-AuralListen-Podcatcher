import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards Android settings that only show up on a real device.
void main() {
  test('cleartext http is allowed (podcast feeds link http:// audio)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(
      manifest,
      contains('android:networkSecurityConfig="@xml/network_security_config"'),
    );
    final config = File(
      'android/app/src/main/res/xml/network_security_config.xml',
    ).readAsStringSync();
    expect(config, contains('<base-config cleartextTrafficPermitted="true">'));
  });

  test('no REQUEST_IGNORE_BATTERY_OPTIMIZATIONS (Google Play policy)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, isNot(contains('REQUEST_IGNORE_BATTERY_OPTIMIZATIONS')));
  });

  test('app name: full in the system, short under the launcher icon', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:label="AA-AuralListen Podcatcher"'));
    expect(manifest, contains('android:label="AuralListen"'));
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(
      gradle,
      contains('applicationId = "io.github.rainerwingel.aurallisten"'),
    );
  });

  test('release builds keep the notification icons', () {
    final keep = File('android/app/src/main/res/raw/keep.xml')
        .readAsStringSync();
    expect(keep, contains('@drawable/audio_service_*'));
    expect(keep, contains('@drawable/ic_stat_podcast'));
  });
}
