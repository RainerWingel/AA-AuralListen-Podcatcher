import 'package:flutter/services.dart';

/// Whether the phone is connected to Android Auto right now (MainActivity.kt
/// asks the system's car connection provider; no library, no permission).
/// The Auto-Sleep-Timer never starts in the car (docs/playback.md) – the
/// sleep timer pausing while driving would be dangerous.
abstract final class CarConnection {
  static const _channel = MethodChannel('aurallisten/car');

  /// False if unknown (no Android Auto installed, not on Android, tests).
  static Future<bool> isConnected() async {
    try {
      return await _channel.invokeMethod<bool>('isConnected') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
