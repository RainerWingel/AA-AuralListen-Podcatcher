import 'package:aapodcastguru/core/perceived_brightness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('luminance grows by the same factor (Weber–Fechner)', () {
    for (final c in [
      const Color(0xFF555555),
      const Color(0xFF8BC34A),
      const Color(0xFFC3C8BB),
    ]) {
      final lifted = perceivedBrighter(c);
      expect(
        lifted.computeLuminance() / c.computeLuminance(),
        closeTo(playerLuminanceFactor, 0.01),
        reason: '$c',
      );
    }
    // Near white: capped at white, never darker.
    expect(perceivedBrighter(const Color(0xFFF0F0F0)), Colors.white);
  });

  test('only dark mode is lifted', () {
    final light = ThemeData(brightness: Brightness.light);
    expect(playerTheme(light), same(light));
    final dark = ThemeData(brightness: Brightness.dark);
    final lifted = playerTheme(dark);
    expect(
      lifted.colorScheme.onSurfaceVariant.computeLuminance(),
      greaterThan(dark.colorScheme.onSurfaceVariant.computeLuminance()),
    );
    expect(
      lifted.colorScheme.primary.computeLuminance(),
      greaterThan(dark.colorScheme.primary.computeLuminance()),
    );
    expect(lifted.colorScheme.surface, dark.colorScheme.surface);
    // Accents get the smaller step.
    expect(
      lifted.colorScheme.primary.computeLuminance() /
          dark.colorScheme.primary.computeLuminance(),
      closeTo(playerAccentFactor, 0.01),
    );
    // The play button keeps its own icon color.
    expect(lifted.iconTheme, dark.iconTheme);
  });
}
