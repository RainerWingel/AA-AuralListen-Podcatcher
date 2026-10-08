import 'package:flutter/material.dart';

/// Episode titles in lists (episode rows, Downloads, history, bookmarks) that
/// do not fit into [titleLines] lines are shown at [longTitleScale] of their
/// size – not in the player or sheets (user wish 2026-10-09; before: from 60
/// characters on, which missed long words and shrank short lines too).
const titleLines = 2;
const longTitleScale = 0.65;

/// [text] in [style] needs more than [maxLines] lines at [maxWidth].
bool textOverflows(
  BuildContext context,
  InlineSpan text, {
  required double maxWidth,
  int maxLines = titleLines,
}) {
  final painter = TextPainter(
    text: text,
    maxLines: maxLines,
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout(maxWidth: maxWidth);
  final overflows = painter.didExceedMaxLines;
  painter.dispose();
  return overflows;
}

/// [style] on top of the surrounding text style, made smaller when [shrink].
TextStyle episodeTitleStyle(
  BuildContext context, {
  required bool shrink,
  TextStyle? style,
}) {
  final base = DefaultTextStyle.of(context).style.merge(style);
  final size = base.fontSize;
  return shrink && size != null
      ? base.copyWith(fontSize: size * longTitleScale)
      : base;
}

/// An episode title in a list: like [Text], but smaller when it does not fit
/// into [maxLines] lines at the normal size.
class EpisodeTitle extends StatelessWidget {
  const EpisodeTitle(
    this.title, {
    this.style,
    this.maxLines = titleLines,
    this.overflow,
    super.key,
  });

  final String title;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final normal = episodeTitleStyle(context, shrink: false, style: style);
      final shrink = textOverflows(
        context,
        TextSpan(text: title, style: normal),
        maxWidth: constraints.maxWidth,
        maxLines: maxLines,
      );
      return Text(
        title,
        style: episodeTitleStyle(context, shrink: shrink, style: style),
        maxLines: maxLines,
        overflow: overflow,
      );
    },
  );
}
