/// Background of the control panel in the full-screen player (Optionen →
/// Design). The enum name is the stored value (`SettingsKeys.panelDesign`) –
/// never rename. All designs are painted in code (no image files) from the
/// app's color scheme, so they follow light/dark mode and the app color.
enum PanelDesign {
  /// The plain surface color (default, as before 1.3.5).
  plain,

  /// Starry sky with a few sparkles.
  stars,

  /// Soft northern-lights ribbons.
  aurora,

  /// Layered waves at the bottom.
  waves,

  /// Low-poly crystal facets.
  facets,

  /// Blotches in several tones, like woodland camouflage.
  camouflage;

  static const standard = PanelDesign.plain;

  static PanelDesign fromSetting(String? value) =>
      values.firstWhere((d) => d.name == value, orElse: () => standard);
}
