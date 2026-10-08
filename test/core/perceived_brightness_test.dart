import 'package:aapodcastguru/core/perceived_brightness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('luminance grows by the given factor (Weber–Fechner)', () {
    for (final c in [const Color(0xFF121412), const Color(0xFF555555)]) {
      final lifted = perceivedBrighter(c, factor: 3);
      expect(
        lifted.computeLuminance() / c.computeLuminance(),
        closeTo(3, 0.02),
        reason: '$c',
      );
    }
    expect(perceivedBrighter(const Color(0xFFF0F0F0), factor: 3), Colors.white);
  });

  test('dark mode: buttons get a brighter background, colors stay', () {
    final light = ThemeData(brightness: Brightness.light);
    expect(playerTheme(light), same(light));
    expect(playerControlBackground(light), isNull);

    final dark = ThemeData(brightness: Brightness.dark);
    final themed = playerTheme(dark);
    final background = playerControlBackground(dark)!;
    expect(
      background.computeLuminance(),
      closeTo(
        dark.colorScheme.surface.computeLuminance() *
            playerButtonBackgroundFactor,
        0.001,
      ),
    );
    expect(
      themed.textButtonTheme.style!.backgroundColor!.resolve({}),
      background,
    );
    expect(
      themed.iconButtonTheme.style!.backgroundColor!.resolve({}),
      background,
    );
    // Symbols and texts keep their colors.
    expect(themed.colorScheme, dark.colorScheme);
  });
}
