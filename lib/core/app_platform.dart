import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Installed version as Android reports it – set by the build from
/// pubspec.yaml, so it never needs to be updated by hand.
typedef InstalledVersion = ({String name, int build});

/// App info from the platform (MainActivity.kt, channel `aurallisten/app`).
abstract interface class AppPlatform {
  /// Null when not on Android (tests, other platforms).
  Future<InstalledVersion?> version();

  /// Opens [url] in the browser. False if that was not possible.
  Future<bool> openUrl(String url);
}

class AndroidAppPlatform implements AppPlatform {
  const AndroidAppPlatform();

  static const _channel = MethodChannel('aurallisten/app');

  @override
  Future<InstalledVersion?> version() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>('version');
      if (map == null) return null;
      final code = (map['build'] as num?)?.toInt() ?? 0;
      return (
        name: map['name'] as String? ?? '?',
        // `--split-per-abi` adds 1000 × ABI to the version code (arm64: 2003);
        // the build number from pubspec.yaml is the rest.
        build: code % 1000,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> openUrl(String url) async {
    try {
      return await _channel.invokeMethod<bool>('openUrl', url) ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

final appPlatformProvider = Provider<AppPlatform>(
  (ref) => const AndroidAppPlatform(),
);

final installedVersionProvider = FutureProvider.autoDispose<InstalledVersion?>(
  (ref) => ref.watch(appPlatformProvider).version(),
);
