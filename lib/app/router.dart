import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/downloads/downloads_screen.dart';
import '../features/episodes/home_screen.dart';
import '../features/playlists/playlists_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import 'app_shell.dart';

/// Route paths, kept in one place to avoid typos.
abstract final class Routes {
  static const home = '/';
  static const subscriptions = '/abos';
  static const playlists = '/playlists';
  static const downloads = '/downloads';
  static const settings = '/einstellungen';
}

/// The app's single [GoRouter]. Disposed together with the provider.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch(Routes.home, const HomeScreen()),
          _branch(Routes.subscriptions, const SubscriptionsScreen()),
          _branch(Routes.playlists, const PlaylistsScreen()),
          _branch(Routes.downloads, const DownloadsScreen()),
          _branch(Routes.settings, const SettingsScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
