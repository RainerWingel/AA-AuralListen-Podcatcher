import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Size of the picture of the episode playing now.
@immutable
class VideoFormat {
  const VideoFormat({
    required this.width,
    required this.height,
    this.pixelRatio = 1,
  });

  final int width;
  final int height;

  /// Width of a pixel relative to its height (anamorphic video).
  final double pixelRatio;

  /// Shown width / height.
  double get aspectRatio => width * pixelRatio / height;

  @override
  bool operator ==(Object other) =>
      other is VideoFormat &&
      other.width == width &&
      other.height == height &&
      other.pixelRatio == pixelRatio;

  @override
  int get hashCode => Object.hash(width, height, pixelRatio);
}

/// The picture of video episodes (docs/playback.md "Video"). The same
/// player that plays the sound renders it onto a Flutter texture – but only
/// while a widget shows it ([acquire]) and the app is visible. Otherwise
/// the video track is off: sound only, nothing decoded in the background.
abstract interface class VideoOutput {
  /// Picture size of the current episode; null = sound only.
  ValueListenable<VideoFormat?> get format;

  /// Texture id to show once a picture is on it; null = show the cover.
  ValueListenable<int?> get picture;

  /// A widget starts showing the picture (counted; pair with [release]).
  void acquire();

  /// The widget from [acquire] is gone.
  void release();

  void dispose();
}

/// [VideoOutput] over the patched just_audio
/// (third_party/just_audio/PATCH.md).
class PlatformVideoOutput implements VideoOutput {
  PlatformVideoOutput({
    this._channel = const MethodChannel('com.ryanheise.just_audio.video'),
  }) {
    _channel.setMethodCallHandler(_onCall);
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    // The format may have been reported before this object existed.
    unawaited(
      _invoke<Map<Object?, Object?>>('videoFormat').then((map) {
        if (!_disposed) _format.value ??= _formatOf(map);
      }),
    );
  }

  final MethodChannel _channel;
  late final AppLifecycleListener _lifecycle;
  final _format = ValueNotifier<VideoFormat?>(null);
  final _picture = ValueNotifier<int?>(null);

  int _users = 0;
  bool _visible = true;
  bool _disposed = false;

  /// Attached texture (picture may still be missing).
  int? _texture;

  /// Attach/detach run one after the other.
  Future<void> _queue = Future.value();

  @override
  ValueListenable<VideoFormat?> get format => _format;

  @override
  ValueListenable<int?> get picture => _picture;

  @override
  void acquire() {
    _users++;
    _update();
  }

  @override
  void release() {
    _users--;
    _update();
  }

  @override
  void dispose() {
    _disposed = true;
    _lifecycle.dispose();
    _channel.setMethodCallHandler(null);
    _update();
    _format.dispose();
    _picture.dispose();
  }

  void _onLifecycle(AppLifecycleState state) {
    // "inactive" (notification shade, app switcher animation) still shows
    // the app; hidden/paused (other app, screen off) does not.
    _visible =
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    _update();
  }

  void _update() => _queue = _queue.then((_) => _apply());

  Future<void> _apply() async {
    final wanted = !_disposed && _users > 0 && _visible;
    if (wanted && _texture == null) {
      _texture = await _invoke<int>('attach');
    } else if (!wanted && _texture != null) {
      _texture = null;
      if (!_disposed) _picture.value = null;
      await _invoke<void>('detach');
    }
  }

  Future<dynamic> _onCall(MethodCall call) async {
    switch (call.method) {
      case 'videoFormat':
        _format.value = _formatOf(call.arguments as Map<Object?, Object?>?);
      case 'firstFrame':
        _picture.value = _texture;
    }
  }

  static VideoFormat? _formatOf(Map<Object?, Object?>? map) => switch (map) {
    {
      'width': final int width,
      'height': final int height,
      'pixelRatio': final num ratio,
    }
        when width > 0 && height > 0 =>
      VideoFormat(
        width: width,
        height: height,
        pixelRatio: ratio > 0 ? ratio.toDouble() : 1,
      ),
    _ => null,
  };

  /// Without the plugin (tests, other platforms) there is no picture.
  Future<T?> _invoke<T>(String method) async {
    try {
      return await _channel.invokeMethod<T>(method);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
