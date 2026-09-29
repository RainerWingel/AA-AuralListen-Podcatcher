import 'package:aapodcastguru/core/app_platform.dart';

/// Records opened links; reports a fixed installed version.
class FakeAppPlatform implements AppPlatform {
  InstalledVersion? installed = (name: '1.2.0', build: 3);
  final opened = <String>[];

  @override
  Future<InstalledVersion?> version() async => installed;

  @override
  Future<bool> openUrl(String url) async {
    opened.add(url);
    return true;
  }
}
