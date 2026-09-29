import 'package:flutter/material.dart';

/// Central theme definitions. Castbox-like orange accent.
abstract final class AppTheme {
  static const Color _seed = Color(0xFFF55B23);

  /// Screen titles (app bars) in Playfair Display – user choice 2026-09-30.
  /// Only the titles: small text stays in the readable system font.
  static const titleFontFamily = 'PlayfairDisplay';

  static ThemeData light() => _withTitleFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      useMaterial3: true,
    ),
  );

  static ThemeData dark() => _withTitleFont(
    ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
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
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        color: theme.colorScheme.onSurface,
      ),
    ),
  );
}
