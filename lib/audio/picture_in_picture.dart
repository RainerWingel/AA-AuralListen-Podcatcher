import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Picture-in-picture of video episodes (docs/playback.md "Video", stage 3):
/// while a playing video is on screen, leaving the app (Home, app switcher)
/// shows it in a small window with −15 s, play/pause and +30 s. MainActivity
/// does the Android part; this side says when it is wanted.
abstract interface class PictureInPicture {
  /// The app shows in the small window right now.
  ValueListenable<bool> get active;

  /// [wanted]: a playing video is on screen. [width]/[height]: its shape.
  /// [labels]: names of the buttons in the window (`rewind`, `play`,
  /// `pause`, `forward`) for TalkBack.
  Future<void> update({
    required bool wanted,
    required bool playing,
    required int width,
    required int height,
    required Map<String, String> labels,
  });

  void dispose();
}

class PlatformPictureInPicture implements PictureInPicture {
  PlatformPictureInPicture({
    this._channel = const MethodChannel('aurallisten/pip'),
  }) {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  final _active = ValueNotifier(false);
  bool _disposed = false;

  /// Last state sent: the same state is not sent twice.
  String? _sent;

  @override
  ValueListenable<bool> get active => _active;

  @override
  Future<void> update({
    required bool wanted,
    required bool playing,
    required int width,
    required int height,
    required Map<String, String> labels,
  }) async {
    final arguments = <String, Object?>{
      'wanted': wanted,
      'playing': playing,
      'width': width,
      'height': height,
      'labels': labels,
    };
    final key = '$wanted $playing $width $height ${labels.entries}';
    if (key == _sent) return;
    _sent = key;
    try {
      await _channel.invokeMethod<void>('update', arguments);
    } on MissingPluginException {
      // Tests, other platforms: no small window.
    } on PlatformException {
      // Same.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _channel.setMethodCallHandler(null);
    _active.dispose();
  }

  Future<dynamic> _onCall(MethodCall call) async {
    if (call.method == 'mode' && !_disposed) {
      _active.value = call.arguments == true;
    }
  }
}
