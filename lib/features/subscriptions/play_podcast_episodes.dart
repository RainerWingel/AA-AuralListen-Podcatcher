import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../playlists/playlist_actions.dart';

/// Long press on a subscription tile: "Alle neuen / ungespielten Episoden
/// spielen" (docs/playlists.md).
Future<void> showPodcastPlayMenu(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast,
) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(podcastRepositoryProvider);
  final fresh = await repo.unplayedEpisodes(podcast.id, freshOnly: true);
  final unplayed = await repo.unplayedEpisodes(podcast.id, freshOnly: false);
  if (!context.mounted) return;
  // The sheet's own context is gone once it closes: the flow uses [context].
  final freshOnly = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              podcast.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fiber_new_outlined),
            title: Text(l10n.playNewEpisodes),
            subtitle: Text(l10n.playNewEpisodesHint(fresh.length)),
            enabled: fresh.isNotEmpty,
            onTap: () => Navigator.of(sheetContext).pop(true),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_play),
            title: Text(l10n.playUnplayedEpisodes),
            subtitle: Text(l10n.episodeCount(unplayed.length)),
            enabled: unplayed.isNotEmpty,
            onTap: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      ),
    ),
  );
  if (freshOnly == null || !context.mounted) return;
  await playPodcastEpisodes(
    context,
    ref,
    freshOnly ? fresh : unplayed,
    title: freshOnly ? l10n.playNewEpisodes : l10n.playUnplayedEpisodes,
  );
}

/// Adds [episodes] (oldest first) to a chosen playlist – skipping those
/// already in it – and starts playing the first of them in that playlist.
Future<void> playPodcastEpisodes(
  BuildContext context,
  WidgetRef ref,
  List<Episode> episodes, {
  required String title,
}) async {
  if (episodes.isEmpty) return;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final playlist = await choosePlaylist(context, ref, title: title);
  if (playlist == null) return;

  final added = await ref.read(playlistRepositoryProvider).addAll(playlist.id, [
    for (final e in episodes) e.id,
  ]);
  await ref
      .read(audioHandlerProvider)
      .playEpisode(episodes.first.id, playlistId: playlist.id);
  showInfoSnackBar(
    messenger,
    l10n.episodesAddedToPlaylist(added.length, playlist.name),
  );
}
