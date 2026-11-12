import 'package:aapodcastguru/audio/video_output.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('test/video');
  late List<String> calls;
  late PlatformVideoOutput output;
  var nextTexture = 7;

  /// A message from the native side (like VideoOutput.java sends it).
  Future<void> fromNative(
    WidgetTester tester,
    String method, [
    Object? arguments,
  ]) => tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    channel.name,
    const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
    (_) {},
  );

  /// Lifecycle changes in the order Android reports them.
  void background(WidgetTester tester) => tester.binding
    ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
    ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  void foreground(WidgetTester tester) => tester.binding
    ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
    ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);

  setUp(() {
    calls = [];
    nextTexture = 7;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return switch (call.method) {
            'attach' => nextTexture++,
            'videoFormat' => {'width': 1920, 'height': 1080, 'pixelRatio': 1.0},
            _ => null,
          };
        });
  });

  tearDown(() {
    output.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('format: asked on start, then reported by the player', (
    tester,
  ) async {
    output = PlatformVideoOutput(channel: channel);
    await tester.pump();
    expect(output.format.value?.aspectRatio, 16 / 9);

    await fromNative(tester, 'videoFormat', {
      'width': 720,
      'height': 576,
      'pixelRatio': 1.4222,
    });
    expect(output.format.value?.aspectRatio, closeTo(16 / 9, 0.001));

    // Sound only.
    await fromNative(tester, 'videoFormat');
    expect(output.format.value, isNull);
  }, timeout: const Timeout(Duration(seconds: 10)));

  testWidgets('one texture while shown; none in the background (sound only)', (
    tester,
  ) async {
    output = PlatformVideoOutput(channel: channel);
    await tester.pump();
    calls.clear();

    // Two widgets (player + full screen) share one texture.
    output
      ..acquire()
      ..acquire();
    await tester.pump();
    expect(calls, ['attach']);
    // The cover shows until the first picture is on the texture.
    expect(output.picture.value, isNull);
    await fromNative(tester, 'firstFrame');
    expect(output.picture.value, 7);

    // Other app or screen off: texture away, picture gone.
    background(tester);
    await tester.pump();
    expect(calls, ['attach', 'detach']);
    expect(output.picture.value, isNull);

    // Back: a new texture, the cover until its first picture.
    foreground(tester);
    await tester.pump();
    expect(calls, ['attach', 'detach', 'attach']);
    expect(output.picture.value, isNull);
    await fromNative(tester, 'firstFrame');
    expect(output.picture.value, 8);

    // Only the last widget gone releases it.
    output.release();
    await tester.pump();
    expect(calls, ['attach', 'detach', 'attach']);
    output.release();
    await tester.pump();
    expect(calls, ['attach', 'detach', 'attach', 'detach']);
    expect(output.picture.value, isNull);

    // Not shown: the background does not attach anything.
    background(tester);
    foreground(tester);
    await tester.pump();
    expect(calls, hasLength(4));
  }, timeout: const Timeout(Duration(seconds: 10)));

  testWidgets('dispose releases an attached texture', (tester) async {
    output = PlatformVideoOutput(channel: channel)..acquire();
    await tester.pump();
    output.dispose();
    await tester.pump();
    expect(calls, ['videoFormat', 'attach', 'detach']);
    // tearDown disposes again: must be harmless.
    output = PlatformVideoOutput(channel: channel);
  }, timeout: const Timeout(Duration(seconds: 10)));

  testWidgets('without the plugin: no picture, no error', (tester) async {
    output = PlatformVideoOutput(channel: const MethodChannel('test/missing'))
      ..acquire();
    await tester.pump();
    expect(output.format.value, isNull);
    expect(output.picture.value, isNull);
  }, timeout: const Timeout(Duration(seconds: 10)));
}
