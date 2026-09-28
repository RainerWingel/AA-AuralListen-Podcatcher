import 'package:flutter/services.dart';

import '../data/settings_keys.dart';
import '../data/settings_repository.dart';

/// Android battery optimisation of this app (docs/playback.md).
///
/// "Optimiert" lets Samsung/Android stop the app during long playback with
/// the screen off. Only the user can change it; the app can show the
/// system dialog that sets "Nicht eingeschränkt" with one tap.
abstract interface class BatteryOptimization {
  /// True if the app is "Nicht eingeschränkt" (ignored by battery optimisation).
  Future<bool> isExempt();

  /// Shows the system dialog. Returns false if it could not be shown.
  Future<bool> requestExemption();

  /// Opens the app's system settings (Akku, Standby lists).
  Future<bool> openAppSettings();
}

/// Talks to MainActivity.kt.
class AndroidBatteryOptimization implements BatteryOptimization {
  const AndroidBatteryOptimization();

  static const _channel = MethodChannel('aapodcastguru/battery');

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
  Future<bool> requestExemption() => _call('requestExemption');

  @override
  Future<bool> openAppSettings() => _call('openAppSettings');
}

/// On the first playback: if the app is still battery-optimised, show the
/// system dialog once. Declining is respected – it never asks again by
/// itself (Optionen → Hören offers it later).
Future<void> askForBatteryExemptionOnce(
  BatteryOptimization battery,
  SettingsRepository settings,
) async {
  if (await settings.get(SettingsKeys.batteryExemptionAsked) != null) return;
  if (await battery.isExempt()) return;
  await settings.set(SettingsKeys.batteryExemptionAsked, 'true');
  await battery.requestExemption();
}
