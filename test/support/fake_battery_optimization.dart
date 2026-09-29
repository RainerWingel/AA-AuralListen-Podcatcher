import 'package:aapodcastguru/audio/battery_optimization.dart';

/// Records what the app asked Android for.
class FakeBatteryOptimization implements BatteryOptimization {
  bool exempt = false;
  int settingsOpened = 0;

  @override
  Future<bool> isExempt() async => exempt;

  @override
  Future<bool> openAppSettings() async {
    settingsOpened++;
    return true;
  }
}
