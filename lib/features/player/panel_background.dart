import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/panel_design.dart';

/// Paints [design] behind [child] – the background of the control panel in
/// the full-screen player (user wish 2026-10-26). The pattern is drawn in
/// code from the current color scheme, so it follows light/dark mode and the
/// app color; it is kept calm (small contrast) so that texts and buttons on
/// top stay readable (test/features/player/panel_background_test.dart).
///
/// Static: one paint inside a [RepaintBoundary], no animation controller.
/// The only exception (user wish 2026-10-27): with [reshuffle] the stars of
/// "Sternenhimmel" are scattered anew every [reshuffleInterval] – one timer
/// that only runs while this widget is shown and the app is in the
/// foreground, one repaint per minute, a short cross-fade.
class PanelBackground extends StatefulWidget {
  const PanelBackground({
    required this.design,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.reshuffle = false,
    super.key,
  });

  /// How often the stars are scattered anew.
  static const reshuffleInterval = Duration(seconds: 60);

  final PanelDesign design;
  final Widget child;

  /// Clips the pattern to the rounded corners of the card around it.
  final BorderRadius borderRadius;

  /// Scatter the stars of [PanelDesign.stars] anew every minute (the player;
  /// the previews in Optionen stay still).
  final bool reshuffle;

  @override
  State<PanelBackground> createState() => _PanelBackgroundState();
}

class _PanelBackgroundState extends State<PanelBackground>
    with WidgetsBindingObserver {
  /// 0 = the standard sky (as in the previews); then random.
  int _seed = 0;
  Timer? _timer;

  bool get _wanted => widget.reshuffle && widget.design == PanelDesign.stars;

  bool get _foreground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTimer();
  }

  @override
  void didUpdateWidget(PanelBackground old) {
    super.didUpdateWidget(old);
    _syncTimer();
  }

  /// No timer in the background (screen off, other app): nobody sees it.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _syncTimer();

  void _syncTimer() {
    final run = _wanted && _foreground;
    if (run && _timer == null) {
      _timer = Timer.periodic(PanelBackground.reshuffleInterval, (_) {
        if (mounted) setState(() => _seed = Random().nextInt(1 << 30));
      });
    } else if (!run) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.design == PanelDesign.plain) return widget.child;
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              // Only a new sky fades in; the other designs never change.
              duration: const Duration(milliseconds: 900),
              child: SizedBox.expand(
                key: ValueKey(_seed),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: PanelDesignPainter(
                      design: widget.design,
                      brightness: scheme.brightness,
                      surface: scheme.surface,
                      primary: scheme.primary,
                      secondary: scheme.secondary,
                      tertiary: scheme.tertiary,
                      seed: _seed,
                    ),
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// Draws one [PanelDesign]. Deterministic for a given [seed]: the pattern never
/// changes between frames or app starts (the stars get a new seed only when
/// [PanelBackground] reshuffles).
class PanelDesignPainter extends CustomPainter {
  const PanelDesignPainter({
    required this.design,
    required this.brightness,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    this.seed = 0,
  });

  /// Varies the random parts (the stars); 0 is the standard sky.
  final int seed;

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
      case PanelDesign.camouflage:
        _camouflage(canvas, size);
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

    final random = Random(7 + seed);
    final count = (size.width * size.height / 1500).round().clamp(40, 170);
    final starColor = _dark ? _mix(Colors.white, primary, 0.15) : primary;
    final dot = Paint();
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      // Mostly tiny, a few bigger ones.
      final big = random.nextDouble();
      final radius = 0.5 + big * big * big * 1.2;
      final alpha = (_dark ? 0.2 : 0.22) + random.nextDouble() * 0.3;
      dot.color = starColor.withValues(alpha: alpha.clamp(0, 0.7));
      canvas.drawCircle(Offset(x, y), radius, dot);
    }
    // A handful of four-pointed sparkles.
    final sparkle = Paint()
      ..color = starColor.withValues(alpha: _dark ? 0.62 : 0.6);
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

  // ------------------------------------------------------------- camouflage

  /// Classic "duck hunter" camouflage (user wish 2026-10-26): a sand colored
  /// ground with large, smooth, flowing blotches in olive, brown and
  /// charcoal, each separated from its neighbours by a thin sand colored gap.
  /// The palette is fixed (that is the look) but washed out in light mode and
  /// darkened in dark mode, so texts and buttons on top stay readable.
  void _camouflage(Canvas canvas, Size size) {
    final ground = _mix(
      _dark ? const Color(0xFF48453A) : const Color(0xFFE0DBC8),
      surface,
      0.1,
    );
    final tones = [
      _dark ? const Color(0xFF34402B) : const Color(0xFFAEBB96), // olive
      _dark ? const Color(0xFF3D3025) : const Color(0xFFC2AE92), // brown
      _dark ? const Color(0xFF14150F) : const Color(0xFFB2B4AA), // charcoal
    ].map((c) => _mix(c, surface, 0.08)).toList();
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);

    final random = Random(5);
    // Blotch size follows the panel (card 190 dp high = 1), so the small
    // previews show the same picture as the real panel.
    final unit = (size.shortestSide / 190).clamp(0.5, 1.4);
    final cell = 50 * unit;
    final gap = 4.5 * unit;
    final blobs = <_Blotch>[];
    for (var row = -1; row * cell < size.height + cell; row++) {
      for (var col = -1; col * cell < size.width + cell; col++) {
        if (random.nextDouble() < 0.04) continue;
        final center = Offset(
          (col + 0.5 + (random.nextDouble() - 0.5) * 0.8) * cell,
          (row + 0.5 + (random.nextDouble() - 0.5) * 0.8) * cell,
        );
        blobs.add(_Blotch.random(random, center, unit));
      }
    }
    // The three tones in turn (in a shuffled order), so each is as frequent
    // as the others.
    blobs.shuffle(random);
    final ground0 = Paint()..color = ground;
    final fill = Paint()..isAntiAlias = true;
    for (var i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      // Later blotches get a sand colored halo that cuts into earlier ones:
      // that makes the thin gaps between neighbours.
      for (final disc in blob.discs) {
        canvas.drawCircle(disc.center, disc.radius + gap, ground0);
      }
      fill.color = tones[i % tones.length];
      for (final disc in blob.discs) {
        canvas.drawCircle(disc.center, disc.radius, fill);
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
      tertiary != old.tertiary ||
      seed != old.seed;
}

/// One camouflage blotch: many overlapping discs along a wiggly line, whose
/// radius swells and shrinks smoothly – that gives the flowing, lumpy outline
/// of the classic pattern. A side branch makes some of them mushroom- or
/// L-shaped.
class _Blotch {
  _Blotch(this.discs);

  factory _Blotch.random(Random random, Offset center, double unit) {
    final angle = random.nextDouble() * pi;
    final direction = Offset(cos(angle), sin(angle));
    final across = Offset(-direction.dy, direction.dx);
    final length = (80 + random.nextDouble() * 90) * unit;
    final width = (14 + random.nextDouble() * 10) * unit; // base radius
    Offset at(double along, double side) =>
        center + direction * (along * length) + across * (side * length);
    final wiggle = (random.nextDouble() - 0.5) * 1.2;
    final a = at(-0.5, 0);
    final b = at(-0.2, wiggle);
    final c = at(0.2, -wiggle);
    final d = at(0.5, 0);

    final discs = <({Offset center, double radius})>[];
    void addLine(Offset Function(double t) point, double span, double scale) {
      final steps = max(8, (span / (width * 0.16)).ceil());
      final phase1 = random.nextDouble() * 2 * pi;
      final phase2 = random.nextDouble() * 2 * pi;
      final freq1 = 1 + random.nextDouble() * 1.5;
      final freq2 = 2.5 + random.nextDouble() * 2;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        // Swelling and shrinking, rounded off at both ends.
        final swell =
            0.62 +
            0.26 * sin(2 * pi * freq1 * t + phase1) +
            0.12 * sin(2 * pi * freq2 * t + phase2);
        final round = 0.55 + 0.45 * sin(pi * t);
        discs.add((
          center: point(t),
          radius: max(width * 0.3, width * scale * swell * round * 1.25),
        ));
      }
    }

    Offset cubic(double t) {
      final u = 1 - t;
      return a * (u * u * u) +
          b * (3 * u * u * t) +
          c * (3 * u * t * t) +
          d * (t * t * t);
    }

    addLine(cubic, length, 1);
    if (random.nextDouble() < 0.5) {
      final from = cubic(0.3 + random.nextDouble() * 0.4);
      final side = random.nextBool() ? 1.0 : -1.0;
      final tip =
          from +
          across * (side * length * (0.35 + random.nextDouble() * 0.3)) +
          direction * (length * (random.nextDouble() - 0.5) * 0.4);
      final bend = (random.nextDouble() - 0.5) * 0.5;
      addLine(
        (t) =>
            Offset.lerp(from, tip, t)! +
            direction * (sin(pi * t) * bend * length),
        (tip - from).distance,
        0.85,
      );
    }
    return _Blotch(discs);
  }

  final List<({Offset center, double radius})> discs;
}
