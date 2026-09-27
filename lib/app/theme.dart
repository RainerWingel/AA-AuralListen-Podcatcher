import 'package:flutter/material.dart';

/// Central theme definitions. Castbox-like orange accent.
abstract final class AppTheme {
  static const Color _seed = Color(0xFFF55B23);

  static ThemeData light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    useMaterial3: true,
  );

  static ThemeData dark() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
