import 'dart:math' show pi;

import 'package:flutter/material.dart';

/// Decorative background of the home screen: three nested arches at the top,
/// strongest outside, fading into the plain surface (user wish 2026-09-30).
/// Drawn as vectors, so it is sharp on every screen; the tones come from the
/// color scheme and work in light and dark mode. Paints nothing interactive.
class ArchBackground extends StatelessWidget {
  const ArchBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Soft tints of the primary color over the surface – subtle enough that
    // the episode text on top stays easy to read.
    Color tint(double alpha) => Color.alphaBlend(
      scheme.primary.withValues(alpha: alpha),
      scheme.surface,
    );
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ArchPainter(
          bands: dark
              ? [tint(0.08), tint(0.13), tint(0.19)]
              : [tint(0.07), tint(0.12), tint(0.18)],
          outline: scheme.surface.withValues(alpha: 0.7),
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Three concentric half-ellipses, symmetric about the vertical middle of the
/// screen. All lengths are in screen widths, so the drawing keeps its
/// proportions on every phone.
class _ArchPainter extends CustomPainter {
  _ArchPainter({required this.bands, required this.outline});

  /// Innermost (lightest) to outermost (strongest).
  final List<Color> bands;
  final Color outline;

  /// Common center of all ellipses, below the visible arches.
  static const _centerY = 1.2;

  /// Innermost ellipse and the step to the next one (x and y separately, so
  /// the bands look evenly wide along the whole curve).
  static const _innerRadiusX = 0.62;
  static const _innerRadiusY = 0.84;
  static const _stepX = 0.20;
  static const _stepY = 0.17;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final center = Offset(w / 2, _centerY * w);
    // Only the part above the center line: the arches end at the screen
    // sides, nothing is drawn further down.
    final top = Path()..addRect(Rect.fromLTRB(0, 0, w, center.dy));
    final fill = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = outline;
    // Innermost ellipse first: its outside is the largest area; each larger
    // ellipse paints a smaller, stronger area on top.
    for (var i = 0; i < bands.length; i++) {
      final oval = Rect.fromCenter(
        center: center,
        width: 2 * (_innerRadiusX + i * _stepX) * w,
        height: 2 * (_innerRadiusY + i * _stepY) * w,
      );
      final area = Path.combine(
        PathOperation.difference,
        top,
        Path()..addOval(oval),
      );
      canvas.drawPath(area, fill..color = bands[i]);
      // Upper half of the ellipse (angles from 180° to 360°).
      canvas.drawArc(oval, pi, pi, false, line);
    }
  }

  @override
  bool shouldRepaint(_ArchPainter old) =>
      old.outline != outline ||
      old.bands.length != bands.length ||
      [for (var i = 0; i < bands.length; i++) old.bands[i] != bands[i]]
          .any((changed) => changed);
}
