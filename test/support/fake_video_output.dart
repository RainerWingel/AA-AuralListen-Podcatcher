import 'package:aapodcastguru/audio/video_output.dart';
import 'package:flutter/foundation.dart';

/// [VideoOutput] without a player: the test sets the format and picture.
class FakeVideoOutput implements VideoOutput {
  @override
  final ValueNotifier<VideoFormat?> format = ValueNotifier(null);

  @override
  final ValueNotifier<int?> picture = ValueNotifier(null);

  /// Widgets showing the picture right now.
  int users = 0;

  @override
  void acquire() => users++;

  @override
  void release() => users--;

  @override
  void dispose() {
    format.dispose();
    picture.dispose();
  }
}
