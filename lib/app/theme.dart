import 'package:flutter/material.dart';

/// Central theme definitions. The whole palette is derived from one seed
/// color, chosen in Optionen (default: Castbox-like orange, AppColor).
abstract final class AppTheme {
  /// Screen titles (app bars) in Fredoka – user choice 2026-09-30.
  /// Only the titles: small text stays in the readable system font.
  static const titleFontFamily = 'Fredoka';

  static ThemeData light(Color seed) => _withTitleFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
    ),
  );

  static ThemeData dark(Color seed) => _withTitleFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
  );

  static ThemeData _withTitleFont(ThemeData theme) => theme.copyWith(
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        fontFamily: titleFontFamily,
        // Variable font: the weight is chosen via its "wght" axis.
        fontWeight: FontWeight.w600,
        fontVariations: const [FontVariation('wght', 600)],
        color: theme.colorScheme.onSurface,
      ),
    ),
  );
}
