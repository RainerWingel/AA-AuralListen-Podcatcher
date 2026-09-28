import 'package:aapodcastguru/audio/battery_optimization.dart';

/// Records what the app asked Android for.
class FakeBatteryOptimization implements BatteryOptimization {
  bool exempt = false;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<bool> isExempt() async => exempt;

  @override
  Future<bool> requestExemption() async {
    requests++;
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    settingsOpened++;
    return true;
  }
}
