import 'package:flutter/material.dart';

/// Weber–Fechner: the eye perceives brightness logarithmically, so an
/// equally noticeable step is the same *factor* of luminance, not the same
/// amount. In dark mode the player lifts its foreground colors by this
/// factor (user wish 2026-10-09).
const playerLuminanceFactor = 1.4;

/// Smaller step for the accent colors (green buttons, slider): ×1.4 made
/// them almost white and the play button's icon hard to see.
const playerAccentFactor = 1.2;

/// [color] mixed with white until its relative luminance is [factor] times
/// as high (capped at white). Dark colors gain a lot, near-white ones little.
Color perceivedBrighter(Color color, {double factor = playerLuminanceFactor}) {
  final target = (color.computeLuminance() * factor).clamp(0.0, 1.0);
  if (color.computeLuminance() >= target) return color;
  var low = 0.0;
  var high = 1.0;
  for (var i = 0; i < 20; i++) {
    final mid = (low + high) / 2;
    if (Color.lerp(color, Colors.white, mid)!.computeLuminance() < target) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return Color.lerp(color, Colors.white, high)!;
}

/// The player's theme: in dark mode buttons, icons, slider, texts and the
/// description section are a bit brighter; light mode stays as it is.
ThemeData playerTheme(ThemeData theme) {
  if (theme.brightness != Brightness.dark) return theme;
  final c = theme.colorScheme;
  final lifted = c.copyWith(
    primary: perceivedBrighter(c.primary, factor: playerAccentFactor),
    secondary: perceivedBrighter(c.secondary, factor: playerAccentFactor),
    tertiary: perceivedBrighter(c.tertiary, factor: playerAccentFactor),
    onSurface: perceivedBrighter(c.onSurface),
    onSurfaceVariant: perceivedBrighter(c.onSurfaceVariant),
    outline: perceivedBrighter(c.outline),
  );
  // No iconTheme override: it would win over the filled play button's own
  // (dark) icon color.
  return theme.copyWith(
    colorScheme: lifted,
    textTheme: theme.textTheme.apply(
      bodyColor: lifted.onSurface,
      displayColor: lifted.onSurface,
    ),
  );
}
