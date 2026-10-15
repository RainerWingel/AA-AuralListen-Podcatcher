import 'package:flutter/material.dart';

/// The color of links in show notes (user wish 2026-10-18: blue, not the
/// white/accent color of the surrounding text). Light blue on dark
/// backgrounds, dark blue on light ones.
const linkBlueOnDark = Color(0xFF8AB4F8);
const linkBlueOnLight = Color(0xFF0B57D0);

/// Theme extension that fixes the link color for a subtree – used where the
/// background is a picture (the player) and the theme's brightness says
/// nothing about it.
@immutable
class LinkColor extends ThemeExtension<LinkColor> {
  const LinkColor(this.color);

  /// The link color for [onDarkBackground].
  factory LinkColor.forBackground({required bool onDarkBackground}) =>
      LinkColor(onDarkBackground ? linkBlueOnDark : linkBlueOnLight);

  final Color color;

  @override
  LinkColor copyWith({Color? color}) => LinkColor(color ?? this.color);

  @override
  LinkColor lerp(LinkColor? other, double t) =>
      LinkColor(Color.lerp(color, other?.color, t) ?? color);
}

/// The link color to use at [context].
Color linkColorOf(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<LinkColor>()?.color ??
      (theme.brightness == Brightness.dark ? linkBlueOnDark : linkBlueOnLight);
}
