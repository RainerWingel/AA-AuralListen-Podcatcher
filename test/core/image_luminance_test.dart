import 'package:aapodcastguru/core/image_luminance.dart';
import 'package:aapodcastguru/core/link_color.dart';
import 'package:aapodcastguru/features/player/player_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('luminanceOfRgba: black, white, mid grey, transparent', () {
    expect(luminanceOfRgba([0, 0, 0, 255, 0, 0, 0, 255]), 0);
    expect(luminanceOfRgba([255, 255, 255, 255]), closeTo(1, 1e-9));
    // sRGB 128 is about 0.216 in linear light.
    expect(luminanceOfRgba([128, 128, 128, 255]), closeTo(0.216, 0.005));
    expect(luminanceOfRgba([255, 255, 255, 0]), 0);
    expect(luminanceOfRgba(const []), isNull);
    // Mean of a white and a black pixel.
    expect(
      luminanceOfRgba([255, 255, 255, 255, 0, 0, 0, 255]),
      closeTo(0.5, 1e-9),
    );
  });

  test('foreground: dark on light pictures, light on dark ones', () {
    expect(backdropForeground(0.9), const Color(0xFF14141A));
    expect(backdropForeground(0.5), const Color(0xFF14141A));
    expect(backdropForeground(0.05), const Color(0xFFF5F5F7));
    expect(backdropForeground(backdropLightThreshold), const Color(0xFFF5F5F7));
  });

  test('backdropTheme colors texts, icons and text buttons', () {
    const ink = Color(0xFF14141A);
    final theme = backdropTheme(ThemeData(brightness: Brightness.dark), ink);
    expect(theme.colorScheme.onSurface, ink);
    expect(theme.colorScheme.primary, ink);
    expect(theme.textTheme.titleLarge?.color, ink);
    expect(theme.iconTheme.color, ink);
  });

  test(
    'links stay blue on any picture: light blue on dark, dark blue on light',
    () {
      final base = ThemeData(brightness: Brightness.dark);
      final onDarkPicture = backdropTheme(base, backdropForeground(0.02));
      final onLightPicture = backdropTheme(base, backdropForeground(0.9));
      expect(onDarkPicture.extension<LinkColor>()?.color, linkBlueOnDark);
      expect(onLightPicture.extension<LinkColor>()?.color, linkBlueOnLight);
    },
  );
}
