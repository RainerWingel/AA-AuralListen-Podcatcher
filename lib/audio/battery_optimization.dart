import 'package:flutter/services.dart';

/// Android battery optimisation of this app (docs/playback.md).
///
/// "Optimiert" lets Samsung/Android stop the app during long playback with
/// the screen off. Only the user can change it: the app shows the status and
/// opens its system settings (Akku → "Nicht eingeschränkt"). It does not ask
/// for the exemption itself – Google Play allows that permission only for a
/// few kinds of apps.
abstract interface class BatteryOptimization {
  /// True if the app is "Nicht eingeschränkt" (ignored by battery optimisation).
  Future<bool> isExempt();

  /// Opens the app's system settings (Akku, Standby lists).
  Future<bool> openAppSettings();
}

/// Talks to MainActivity.kt.
class AndroidBatteryOptimization implements BatteryOptimization {
  const AndroidBatteryOptimization();

  static const _channel = MethodChannel('aurallisten/battery');

  Future<bool> _call(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException {
      return false; // not on Android (tests, other platforms)
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> isExempt() => _call('isExempt');

  @override
  Future<bool> openAppSettings() => _call('openAppSettings');
}
