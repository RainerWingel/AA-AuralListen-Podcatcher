import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Average relative luminance (0 = black … 1 = white) of [provider], measured
/// on a tiny copy of the picture. Null if the picture cannot be loaded.
Future<double?> averageLuminance(ImageProvider provider) async {
  final completer = Completer<double?>();
  final tiny = ResizeImage(provider, width: 16);
  final stream = tiny.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      // The listener owns [info]: read the pixels, then release it.
      unawaited(
        info.image
            .toByteData()
            .then((data) {
              if (!completer.isCompleted) {
                completer.complete(
                  data == null
                      ? null
                      : luminanceOfRgba(data.buffer.asUint8List()),
                );
              }
            })
            .catchError((Object _) {
              if (!completer.isCompleted) completer.complete(null);
            })
            .whenComplete(info.dispose),
      );
    },
    onError: (Object error, StackTrace? stackTrace) {
      if (!completer.isCompleted) completer.complete(null);
    },
  );
  stream.addListener(listener);
  try {
    return await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => null,
    );
  } finally {
    stream.removeListener(listener);
    // The 16 px copy is of no use afterwards: do not leave it in the cache.
    await tiny.evict();
  }
}

/// Mean relative luminance of raw RGBA pixels (sRGB, WCAG weights); fully
/// transparent pixels count as black.
double? luminanceOfRgba(List<int> rgba) {
  var sum = 0.0;
  var count = 0;
  for (var i = 0; i + 3 < rgba.length; i += 4) {
    final alpha = rgba[i + 3] / 255;
    sum +=
        alpha *
        (0.2126 * _linear(rgba[i]) +
            0.7152 * _linear(rgba[i + 1]) +
            0.0722 * _linear(rgba[i + 2]));
    count++;
  }
  return count == 0 ? null : sum / count;
}

double _linear(int channel) {
  final c = channel / 255;
  return c <= 0.03928
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}
