import 'package:aapodcastguru/audio/battery_optimization.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_battery_optimization.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late FakeBatteryOptimization battery;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepository(db);
    battery = FakeBatteryOptimization();
  });
  tearDown(() => db.close());

  test('asks once while optimised, never again after declining', () async {
    await askForBatteryExemptionOnce(battery, settings);
    expect(battery.requests, 1);
    // Declined in the system dialog: still optimised, but no second prompt.
    await askForBatteryExemptionOnce(battery, settings);
    expect(battery.requests, 1);
  });

  test('does not ask when already "Nicht eingeschränkt"', () async {
    battery.exempt = true;
    await askForBatteryExemptionOnce(battery, settings);
    expect(battery.requests, 0);
    // Later optimised again (user changed it): the automatic prompt is
    // still available once.
    battery.exempt = false;
    await askForBatteryExemptionOnce(battery, settings);
    expect(battery.requests, 1);
  });

  test('without Android (tests, other platforms) it reports false', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const android = AndroidBatteryOptimization();
    expect(await android.isExempt(), isFalse);
    expect(await android.requestExemption(), isFalse);
  });
}
