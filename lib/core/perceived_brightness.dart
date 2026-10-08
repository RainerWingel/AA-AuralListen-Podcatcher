import 'package:flutter/material.dart';

/// Weber–Fechner: the eye perceives brightness logarithmically, so an
/// equally noticeable step is the same *factor* of luminance, not the same
/// amount. Against the near-black background of the dark mode a small lift
/// is already clearly visible: the player's buttons and its description
/// section get a background this many times as luminous as the page
/// (user wish 2026-10-09).
const playerButtonBackgroundFactor = 3.0;

/// The thin outline of the description section and the −15/+30 buttons is
/// this many times as luminous as their background (user wish 2026-10-09; 2× at one physical pixel was
/// far too thin and dark).
const playerOutlineFactor = 5.0;

/// [color] mixed with white until its relative luminance is [factor] times
/// as high (capped at white).
Color perceivedBrighter(Color color, {required double factor}) {
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

/// Background for the player's buttons and description section in dark
/// mode; null in light mode (unchanged there).
Color? playerControlBackground(ThemeData theme) =>
    theme.brightness == Brightness.dark
    ? perceivedBrighter(
        theme.colorScheme.surface,
        factor: playerButtonBackgroundFactor,
      )
    : null;

/// Thin outline of the player's description section and −15/+30 buttons in
/// dark mode; null in light mode.
Color? playerOutline(ThemeData theme) =>
    switch (playerControlBackground(theme)) {
      final background? => perceivedBrighter(
        background,
        factor: playerOutlineFactor,
      ),
      null => null,
    };

/// The player's theme: in dark mode text and icon buttons sit on a slightly
/// brighter background; their symbols and texts keep their colors.
ThemeData playerTheme(ThemeData theme) {
  final background = playerControlBackground(theme);
  if (background == null) return theme;
  return theme.copyWith(
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(backgroundColor: background),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(backgroundColor: background),
    ),
  );
}
