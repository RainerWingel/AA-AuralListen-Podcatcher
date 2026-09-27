import 'dart:async';

import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Runs before every test file: a test file fails if a disposable object
/// (controller, notifier, …) was created in a widget test and garbage
/// collected without dispose() (docs/eviction.md → Tests).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LeakTesting.enable();
  await testMain();
}
