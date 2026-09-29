import 'package:aapodcastguru/audio/battery_optimization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('without Android (tests, other platforms) it reports false', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const android = AndroidBatteryOptimization();
    expect(await android.isExempt(), isFalse);
    expect(await android.openAppSettings(), isFalse);
  });
}
