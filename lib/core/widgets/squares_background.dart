import 'dart:math' show pow;

import 'package:flutter/material.dart';

/// Decorative background of the Downloads screen (user wish 2026-09-30):
/// a grid of squares filling a triangle in the top-left corner. The further a
/// square is from the corner (column + row = its "step"), the smaller and
/// paler it is, and the grid cells grow, so the gaps widen. Everything
/// follows geometric sequences – no randomness. Drawn as vectors, tinted
/// from the color scheme; all lengths are in screen widths.
class SquaresBackground extends StatelessWidget {
  const SquaresBackground({super.key});

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _SquaresPainter(Theme.of(context).colorScheme.primary),
      size: Size.infinite,
    ),
  );
}

class _SquaresPainter extends CustomPainter {
  _SquaresPainter(this.color);

  final Color color;

  /// Squares are drawn up to this step (column + row): the triangle.
  static const _maxStep = 11;

  /// Width of the first grid column/row; each next one × [_cellGrowth].
  static const _firstCell = 0.092;
  static const _cellGrowth = 1.07;

  /// Side of the corner square; each step further × [_shrink].
  static const _firstSide = 0.085;
  static const _shrink = 0.92;

  /// Color strength of the corner square; each step further × [_fade].
  static const _firstAlpha = 0.2;
  static const _fade = 0.88;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // Start and width of each column (rows use the same values).
    final cells = [
      for (var i = 0; i <= _maxStep; i++)
        _firstCell * pow(_cellGrowth, i).toDouble() * w,
    ];
    final starts = <double>[0];
    for (var i = 0; i < _maxStep; i++) {
      starts.add(starts[i] + cells[i]);
    }

    final paint = Paint()..style = PaintingStyle.fill;
    for (var col = 0; col <= _maxStep; col++) {
      for (var row = 0; col + row <= _maxStep; row++) {
        final step = col + row;
        final side = _firstSide * pow(_shrink, step).toDouble() * w;
        final center = Offset(
          starts[col] + cells[col] / 2,
          starts[row] + cells[row] / 2,
        );
        paint.color = color.withValues(
          alpha: _firstAlpha * pow(_fade, step).toDouble(),
        );
        canvas.drawRect(
          Rect.fromCenter(center: center, width: side, height: side),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SquaresPainter old) => old.color != color;
}
