import 'package:aapodcastguru/audio/picture_in_picture.dart';
import 'package:flutter/foundation.dart';

/// [PictureInPicture] without Android: records what the app asks for; the
/// test switches the small window on and off via [active].
class FakePictureInPicture implements PictureInPicture {
  @override
  final ValueNotifier<bool> active = ValueNotifier(false);

  /// Last `update`: whether leaving the app would show the small window.
  bool wanted = false;
  bool playing = false;
  (int, int)? size;
  Map<String, String> labels = const {};

  @override
  Future<void> update({
    required bool wanted,
    required bool playing,
    required int width,
    required int height,
    required Map<String, String> labels,
  }) async {
    this.wanted = wanted;
    this.playing = playing;
    size = (width, height);
    this.labels = labels;
  }

  @override
  void dispose() => active.dispose();
}
