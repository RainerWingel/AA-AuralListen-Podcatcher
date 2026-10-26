import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:aapodcastguru/core/panel_design.dart';
import 'package:aapodcastguru/features/player/panel_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Paints [design] like the player's panel (portrait card size) and returns
/// the RGBA pixels.
Future<({Uint8List rgba, int width, int height})> paintPanel(
  PanelDesign design,
  ColorScheme scheme, {
  int width = 360,
  int height = 300,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = scheme.surface,
    );
  PanelDesignPainter(
    design: design,
    brightness: scheme.brightness,
    surface: scheme.surface,
    primary: scheme.primary,
    secondary: scheme.secondary,
    tertiary: scheme.tertiary,
  ).paint(canvas, Size(width.toDouble(), height.toDouble()));
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = (await image.toByteData())!;
  image.dispose();
  picture.dispose();
  return (rgba: data.buffer.asUint8List(), width: width, height: height);
}

/// WCAG contrast ratio of two colors.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  const seeds = {
    'orange': Color(0xFFF55B23),
    'red': Color(0xFFD32F2F),
    'purple': Color(0xFF7E57C2),
    'blue': Color(0xFF1E88E5),
    'teal': Color(0xFF00897B),
    'green': Color(0xFF43A047),
    'brown': Color(0xFF795548),
  };
  final designs = PanelDesign.values.where((d) => d != PanelDesign.plain);

  // Texts and buttons lie on the pattern: a tiny star is no problem, but no
  // area (12 x 12 px average) may get so pale or dark that the text color
  // loses its contrast (6:1, stricter than WCAG AA 4.5:1) – in light and dark
  // mode, for every app color.
  for (final design in designs) {
    for (final brightness in Brightness.values) {
      test('${design.name} keeps text readable (${brightness.name})', () async {
        var worst = double.infinity;
        for (final entry in seeds.entries) {
          final scheme = ColorScheme.fromSeed(
            seedColor: entry.value,
            brightness: brightness,
          );
          final panel = await paintPanel(design, scheme);
          for (var by = 0; by + 12 <= panel.height; by += 12) {
            for (var bx = 0; bx + 12 <= panel.width; bx += 12) {
              var r = 0, g = 0, b = 0;
              for (var y = by; y < by + 12; y++) {
                for (var x = bx; x < bx + 12; x++) {
                  final i = (y * panel.width + x) * 4;
                  r += panel.rgba[i];
                  g += panel.rgba[i + 1];
                  b += panel.rgba[i + 2];
                }
              }
              final average = Color.fromARGB(255, r ~/ 144, g ~/ 144, b ~/ 144);
              final ratio = contrast(scheme.onSurface, average);
              worst = min(worst, ratio);
              // Secondary texts (onSurfaceVariant) must at least reach AA.
              expect(
                contrast(scheme.onSurfaceVariant, average),
                greaterThanOrEqualTo(4.5),
                reason: '${entry.key}: secondary text at ($bx, $by)',
              );
              expect(
                ratio,
                greaterThanOrEqualTo(6),
                reason:
                    '${entry.key}: text on the pattern at ($bx, $by) '
                    'has contrast ${ratio.toStringAsFixed(2)}',
              );
            }
          }
        }
        // Visible in the test output when the margin gets thin.
        // ignore: avoid_print
        print(
          '${design.name}/${brightness.name}: worst ${worst.toStringAsFixed(2)}',
        );
      });
    }
  }

  test('a design is not just the plain surface (it really draws)', () async {
    final scheme = ColorScheme.fromSeed(seedColor: seeds['orange']!);
    final plain = await paintPanel(PanelDesign.plain, scheme);
    for (final design in designs) {
      final painted = await paintPanel(design, scheme);
      var different = 0;
      for (var i = 0; i < painted.rgba.length; i += 4) {
        if (painted.rgba[i] != plain.rgba[i] ||
            painted.rgba[i + 1] != plain.rgba[i + 1] ||
            painted.rgba[i + 2] != plain.rgba[i + 2]) {
          different++;
        }
      }
      expect(
        different,
        greaterThan(painted.width * painted.height ~/ 4),
        reason: design.name,
      );
    }
  });

  test('the pattern is the same every time (fixed seeds)', () async {
    final scheme = ColorScheme.fromSeed(seedColor: seeds['blue']!);
    for (final design in designs) {
      final a = await paintPanel(design, scheme);
      final b = await paintPanel(design, scheme);
      expect(a.rgba, b.rgba, reason: design.name);
    }
  });

  test('colors and brightness change the picture (dark mode aware)', () async {
    for (final design in designs) {
      final light = await paintPanel(
        design,
        ColorScheme.fromSeed(seedColor: seeds['teal']!),
      );
      final dark = await paintPanel(
        design,
        ColorScheme.fromSeed(
          seedColor: seeds['teal']!,
          brightness: Brightness.dark,
        ),
      );
      final red = await paintPanel(
        design,
        ColorScheme.fromSeed(seedColor: seeds['red']!),
      );
      expect(light.rgba, isNot(dark.rgba), reason: design.name);
      expect(light.rgba, isNot(red.rgba), reason: design.name);
    }
  });

  test('PanelDesign.fromSetting falls back to the plain panel', () {
    expect(PanelDesign.fromSetting(null), PanelDesign.plain);
    expect(PanelDesign.fromSetting('gibtsnicht'), PanelDesign.plain);
    for (final design in PanelDesign.values) {
      expect(PanelDesign.fromSetting(design.name), design);
    }
  });
}
