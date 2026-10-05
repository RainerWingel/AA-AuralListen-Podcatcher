import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../audio/audio_providers.dart';
import '../audio/podcast_audio_handler.dart';
import '../core/widgets/info_snack_bar.dart';
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
    ref.listen(playbackProblemsProvider, (_, next) {
      final problem = next.value?.problem;
      if (problem == null) return;
      // Streams the server builds anew per request: offer the download
      // for the episode playing now (docs/playback.md).
      final handler = ref.read(audioHandlerProvider);
      final episodeId = handler.currentEpisodeId;
      final provisional =
          handler.mediaItem.value?.extras?['provisional'] == true;
      final download = episodeId == null || provisional
          ? null
          : SnackBarAction(
              label: l10n.download,
              onPressed: () =>
                  ref.read(downloadServiceProvider).download(episodeId),
            );
      showInfoSnackBar(
        ScaffoldMessenger.of(context),
        switch (problem) {
          PlaybackProblem.loadFailed => l10n.playbackLoadFailed,
          PlaybackProblem.stalled => l10n.playbackStalled,
          PlaybackProblem.brokenDownload => l10n.playbackBrokenDownload,
          PlaybackProblem.episodeGone => l10n.playbackEpisodeGone,
          PlaybackProblem.unsupportedFormat => l10n.playbackUnsupported,
          PlaybackProblem.streamChanged => l10n.playbackStreamChanged,
          PlaybackProblem.streamVaries => l10n.playbackStreamVaries,
        },
        action: switch (problem) {
          PlaybackProblem.streamChanged ||
          PlaybackProblem.streamVaries => download,
          _ => null,
        },
      );
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
