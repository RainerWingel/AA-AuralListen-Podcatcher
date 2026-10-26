import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/panel_design.dart';

/// Paints [design] behind [child] – the background of the control panel in
/// the full-screen player (user wish 2026-10-26). The pattern is drawn in
/// code from the current color scheme, so it follows light/dark mode and the
/// app color; it is kept calm (small contrast) so that texts and buttons on
/// top stay readable (test/features/player/panel_background_test.dart).
///
/// Static on purpose: one paint inside a [RepaintBoundary], no timers or
/// animation controllers – nothing to leak, cheap on weak phones.
class PanelBackground extends StatelessWidget {
  const PanelBackground({
    required this.design,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final PanelDesign design;
  final Widget child;

  /// Clips the pattern to the rounded corners of the card around it.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (design == PanelDesign.plain) return child;
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: PanelDesignPainter(
                  design: design,
                  brightness: scheme.brightness,
                  surface: scheme.surface,
                  primary: scheme.primary,
                  secondary: scheme.secondary,
                  tertiary: scheme.tertiary,
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Draws one [PanelDesign]. Deterministic: fixed seeds, so the pattern never
/// changes between frames or app starts.
class PanelDesignPainter extends CustomPainter {
  const PanelDesignPainter({
    required this.design,
    required this.brightness,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  final PanelDesign design;
  final Brightness brightness;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  bool get _dark => brightness == Brightness.dark;

  static Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    switch (design) {
      case PanelDesign.plain:
        break;
      case PanelDesign.stars:
        _stars(canvas, size);
      case PanelDesign.aurora:
        _aurora(canvas, size);
      case PanelDesign.waves:
        _waves(canvas, size);
      case PanelDesign.facets:
        _facets(canvas, size);
    }
  }

  /// Vertical gradient from [top] to [bottom] over the whole panel.
  void _fill(Canvas canvas, Size size, Color top, Color bottom) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
  }

  // ------------------------------------------------------------------ stars

  void _stars(Canvas canvas, Size size) {
    // Night sky with a glow of the app color at the horizon; by day a pale
    // dawn sky with sparkles in the app color.
    _fill(
      canvas,
      size,
      _dark ? _mix(surface, Colors.black, 0.5) : _mix(surface, primary, 0.13),
      _dark ? _mix(surface, primary, 0.27) : _mix(surface, primary, 0.05),
    );
    // A soft nebula in one corner.
    final nebula = Rect.fromCircle(
      center: Offset(size.width * 0.85, size.height * 0.2),
      radius: size.shortestSide * 0.9,
    );
    canvas.drawRect(
      nebula,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _mix(tertiary, surface, _dark ? 0.55 : 0.7).withValues(alpha: 0.4),
            _mix(tertiary, surface, _dark ? 0.55 : 0.7).withValues(alpha: 0),
          ],
        ).createShader(nebula),
    );

    final random = Random(7);
    final count = (size.width * size.height / 1500).round().clamp(40, 170);
    final starColor = _dark ? _mix(Colors.white, primary, 0.15) : primary;
    final dot = Paint();
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      // Mostly tiny, a few bigger ones.
      final big = random.nextDouble();
      final radius = 0.5 + big * big * big * 1.2;
      final alpha = (_dark ? 0.28 : 0.22) + random.nextDouble() * 0.35;
      dot.color = starColor.withValues(alpha: alpha.clamp(0, 0.7));
      canvas.drawCircle(Offset(x, y), radius, dot);
    }
    // A handful of four-pointed sparkles.
    final sparkle = Paint()
      ..color = starColor.withValues(alpha: _dark ? 0.8 : 0.6);
    for (var i = 0; i < 7; i++) {
      final center = Offset(
        size.width * (0.08 + random.nextDouble() * 0.84),
        size.height * (0.06 + random.nextDouble() * 0.88),
      );
      final r = 3.5 + random.nextDouble() * 3;
      final path = Path()
        ..moveTo(center.dx, center.dy - r)
        ..quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy)
        ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r)
        ..quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy)
        ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r)
        ..close();
      canvas.drawPath(path, sparkle);
    }
  }

  // ----------------------------------------------------------------- aurora

  void _aurora(Canvas canvas, Size size) {
    _fill(
      canvas,
      size,
      _dark ? _mix(surface, Colors.black, 0.4) : _mix(surface, primary, 0.1),
      _dark ? _mix(surface, secondary, 0.14) : _mix(surface, secondary, 0.05),
    );
    final colors = [primary, tertiary, secondary];
    final bands = [
      (y: 0.25, amplitude: 0.1, phase: 0.0, thickness: 0.26),
      (y: 0.5, amplitude: 0.12, phase: 1.7, thickness: 0.3),
      (y: 0.75, amplitude: 0.09, phase: 3.1, thickness: 0.24),
    ];
    for (var i = 0; i < bands.length; i++) {
      final band = bands[i];
      final color = _dark ? colors[i] : _mix(colors[i], surface, 0.1);
      final alpha = _dark ? 0.3 : 0.32;
      final top = Path();
      final bottom = <Offset>[];
      const steps = 24;
      for (var s = 0; s <= steps; s++) {
        final t = s / steps;
        final x = size.width * t;
        final wave = sin(t * 2 * pi * 1.3 + band.phase);
        final y =
            size.height * (band.y + band.amplitude * wave) -
            size.height * band.thickness / 2;
        if (s == 0) {
          top.moveTo(x, y);
        } else {
          top.lineTo(x, y);
        }
        bottom.add(Offset(x, y + size.height * band.thickness));
      }
      for (final point in bottom.reversed) {
        top.lineTo(point.dx, point.dy);
      }
      top.close();
      final bounds = top.getBounds();
      canvas.drawPath(
        top,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(bounds),
      );
    }
  }

  // ------------------------------------------------------------------ waves

  void _waves(Canvas canvas, Size size) {
    _fill(
      canvas,
      size,
      _dark ? _mix(surface, Colors.black, 0.25) : _mix(surface, primary, 0.06),
      _dark ? _mix(surface, primary, 0.1) : _mix(surface, primary, 0.02),
    );
    final colors = [primary, tertiary, secondary, primary];
    for (var i = 0; i < 4; i++) {
      final base = size.height * (0.38 + i * 0.17);
      final amplitude = size.height * (0.045 + i * 0.006);
      final path = Path()..moveTo(0, size.height);
      const steps = 40;
      for (var s = 0; s <= steps; s++) {
        final t = s / steps;
        path.lineTo(
          size.width * t,
          base + amplitude * sin(t * 2 * pi * (1.2 + i * 0.35) + i * 1.3),
        );
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      final strength = (_dark ? 0.11 : 0.09) + i * (_dark ? 0.05 : 0.035);
      canvas.drawPath(
        path,
        Paint()..color = _mix(surface, colors[i], strength),
      );
    }
  }

  // ----------------------------------------------------------------- facets

  void _facets(Canvas canvas, Size size) {
    // A jittered grid of triangles, each tinted a little differently; lighter
    // towards the top left like a lit crystal.
    final columns = max(4, (size.width / 70).round());
    final rows = max(3, (size.height / 70).round());
    final random = Random(11);
    final cell = Size(size.width / columns, size.height / rows);
    final points = List.generate(rows + 1, (r) {
      return List.generate(columns + 1, (c) {
        final edgeX = c == 0 || c == columns;
        final edgeY = r == 0 || r == rows;
        final dx = edgeX ? 0.0 : (random.nextDouble() - 0.5) * cell.width * 0.7;
        final dy = edgeY
            ? 0.0
            : (random.nextDouble() - 0.5) * cell.height * 0.7;
        return Offset(c * cell.width + dx, r * cell.height + dy);
      });
    });
    final base = _dark ? _mix(surface, Colors.black, 0.3) : surface;
    final paint = Paint()..isAntiAlias = true;
    void triangle(Offset a, Offset b, Offset c, double light) {
      final noise = random.nextDouble();
      final strength = (_dark ? 0.03 : 0.025) + noise * (_dark ? 0.13 : 0.11);
      var color = _mix(base, noise > 0.5 ? primary : tertiary, strength);
      // Light falls from the top left.
      color = _mix(
        color,
        _dark ? Colors.white : Colors.white,
        light * (_dark ? 0.05 : 0.3),
      );
      paint.color = color;
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy)
          ..close(),
        paint,
      );
    }

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        final a = points[r][c];
        final b = points[r][c + 1];
        final d = points[r + 1][c];
        final e = points[r + 1][c + 1];
        final light = 1 - (c / columns + r / rows) / 2;
        triangle(a, b, d, light);
        triangle(b, e, d, light * 0.8);
      }
    }
  }

  @override
  bool shouldRepaint(PanelDesignPainter old) =>
      design != old.design ||
      brightness != old.brightness ||
      surface != old.surface ||
      primary != old.primary ||
      secondary != old.secondary ||
      tertiary != old.tertiary;
}
