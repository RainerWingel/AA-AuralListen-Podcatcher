import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bookmarks/bookmarks_screen.dart';
import '../features/downloads/downloads_screen.dart';
import '../features/episodes/home_screen.dart';
import '../features/player/player_screen.dart';
import '../features/playlists/playlist_screen.dart';
import '../features/playlists/playlists_screen.dart';
import '../features/search/search_screen.dart';
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
      // Outside the shell: covers the bottom navigation, slides up like a sheet.
      GoRoute(
        path: Routes.player,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const PlayerScreen(),
          transitionsBuilder: (context, animation, secondary, child) =>
              SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(
                      CurveTween(curve: Curves.easeOutCubic).animate(animation),
                    ),
                child: child,
              ),
        ),
      ),
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
                    path: 'suche',
                    builder: (context, state) => const SearchScreen(),
                  ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.playlists,
                builder: (context, state) => const PlaylistsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => PlaylistScreen(
                      playlistId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _branch(Routes.downloads, const DownloadsScreen()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'lesezeichen',
                    builder: (context, state) => const BookmarksScreen(),
                  ),
                ],
              ),
            ],
          ),
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
