import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../audio/audio_providers.dart';
import '../audio/battery_optimization.dart';
import '../data/providers.dart';
import '../features/player/mini_player.dart';
import '../l10n/app_localizations.dart';

/// Scaffold with the bottom navigation bar shared by all top-level tabs.
/// The mini player sits between the body and the navigation bar.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // First playback: offer "Nicht eingeschränkt" once, so Samsung does not
    // stop long playback with the screen off (docs/playback.md).
    ref.listen(playbackStateProvider, (previous, next) {
      final wasPlaying = previous?.value?.playing ?? false;
      if (!wasPlaying && (next.value?.playing ?? false)) {
        unawaited(
          askForBatteryExemptionOnce(
            ref.read(batteryOptimizationProvider),
            ref.read(settingsRepositoryProvider),
          ),
        );
      }
    });
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view),
                label: l10n.navSubscriptions,
              ),
              NavigationDestination(
                icon: const Icon(Icons.playlist_play_outlined),
                selectedIcon: const Icon(Icons.playlist_play),
                label: l10n.navPlaylists,
              ),
              NavigationDestination(
                icon: const Icon(Icons.download_outlined),
                selectedIcon: const Icon(Icons.download),
                label: l10n.navDownloads,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.navSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
