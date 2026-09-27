import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/downloads/downloads_screen.dart';
import '../features/episodes/home_screen.dart';
import '../features/playlists/playlists_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/subscriptions/podcast_detail_screen.dart';
import '../features/subscriptions/subscriptions_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.subscriptions,
                builder: (context, state) => const SubscriptionsScreen(),
                routes: [
                  GoRoute(
                    path: 'podcast/:id',
                    builder: (context, state) => PodcastDetailScreen(
                      podcastId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
