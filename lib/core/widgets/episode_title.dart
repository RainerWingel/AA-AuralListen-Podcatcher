import 'package:flutter/material.dart';

/// Episode titles of [longTitleLength] characters or more are shown at
/// [longTitleScale] of their normal size – in lists (episode rows,
/// Downloads, history, bookmarks), not in the player or sheets (user wish
/// 2026-10-09).
const longTitleLength = 60;
const longTitleScale = 0.65;

bool isLongEpisodeTitle(String title) =>
    title.characters.length >= longTitleLength;

/// [style] (on top of the surrounding text style) made smaller for a long
/// [title]; for places that need a style, e.g. a [TextSpan].
TextStyle episodeTitleStyle(
  BuildContext context,
  String title, [
  TextStyle? style,
]) {
  final base = DefaultTextStyle.of(context).style.merge(style);
  final size = base.fontSize;
  return isLongEpisodeTitle(title) && size != null
      ? base.copyWith(fontSize: size * longTitleScale)
      : base;
}

/// An episode title: like [Text], but smaller when it is long.
class EpisodeTitle extends StatelessWidget {
  const EpisodeTitle(
    this.title, {
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final String title;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: episodeTitleStyle(context, title, style),
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
  );
}
