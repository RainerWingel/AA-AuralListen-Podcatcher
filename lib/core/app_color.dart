import 'dart:ui' show Color;

/// Main color of the app (Optionen → Darstellung → App-Farbe). Material 3
/// derives the whole light and dark palette from it; the backgrounds of Home
/// and Downloads use it too. The enum name is the stored value
/// (`SettingsKeys.appColor`) – never rename.
enum AppColor {
  orange(Color(0xFFF55B23)),
  red(Color(0xFFD32F2F)),
  pink(Color(0xFFD81B60)),
  purple(Color(0xFF7E57C2)),
  blue(Color(0xFF1E88E5)),
  teal(Color(0xFF00897B)),
  green(Color(0xFF43A047)),
  brown(Color(0xFF795548)),

  /// Taken from the phone's wallpaper (Android 12+); falls back to [fallback]
  /// where the system offers no wallpaper colors. The default.
  wallpaper(null);

  const AppColor(this.seed);

  /// Seed of the palette; null for [wallpaper] (known only at runtime).
  final Color? seed;

  /// Used while nothing is chosen (user wish 2026-09-30).
  static const standard = AppColor.wallpaper;

  /// Castbox-like orange: for phones without wallpaper colors.
  static const fallback = AppColor.orange;

  static AppColor fromSetting(String? value) =>
      values.firstWhere((c) => c.name == value, orElse: () => standard);
}
