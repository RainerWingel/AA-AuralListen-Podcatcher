import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../audio/audio_providers.dart';
import '../../core/clock.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/feed/rss_parser.dart' show themeDisplayName;
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../playlists/playlist_actions.dart';

enum _PlayChoice { fresh, since, all }

/// Long press on a subscription tile: "Alle neuen Episoden spielen",
/// "Ungespielte Episoden seit … spielen", "Alle ungespielten Episoden
/// spielen" (docs/playlists.md). With [theme] (long press on a topic in the
/// podcast settings) only that topic's episodes count.
Future<void> showPodcastPlayMenu(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast, {
  String? theme,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(podcastRepositoryProvider);
  final fresh = await repo.unplayedEpisodes(
    podcast.id,
    freshOnly: true,
    theme: theme,
  );
  final unplayed = await repo.unplayedEpisodes(
    podcast.id,
    freshOnly: false,
    theme: theme,
  );
  if (!context.mounted) return;
  // The sheet's own context is gone once it closes: the flow uses [context].
  final choice = await showModalBottomSheet<_PlayChoice>(
    context: context,
    showDragHandle: true,
    // Own height, scrollable: three entries with subtitles do not fit the
    // default sheet height with large fonts.
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                theme == null
                    ? podcast.title
                    : '${podcast.title} · ${themeDisplayName(theme)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fiber_new_outlined),
              title: Text(l10n.playNewEpisodes),
              subtitle: Text(l10n.playNewEpisodesHint(fresh.length)),
              enabled: fresh.isNotEmpty,
              onTap: () => Navigator.of(sheetContext).pop(_PlayChoice.fresh),
            ),
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.playUnplayedSince),
              subtitle: Text(l10n.playUnplayedSinceHint),
              enabled: unplayed.isNotEmpty,
              onTap: () => Navigator.of(sheetContext).pop(_PlayChoice.since),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: Text(l10n.playUnplayedEpisodes),
              subtitle: Text(l10n.episodeCount(unplayed.length)),
              enabled: unplayed.isNotEmpty,
              onTap: () => Navigator.of(sheetContext).pop(_PlayChoice.all),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case _PlayChoice.fresh:
      await playPodcastEpisodes(
        context,
        ref,
        fresh,
        title: l10n.playNewEpisodes,
      );
    case _PlayChoice.all:
      await playPodcastEpisodes(
        context,
        ref,
        unplayed,
        title: l10n.playUnplayedEpisodes,
      );
    case _PlayChoice.since:
      await _playUnplayedSince(context, ref, podcast, unplayed, theme: theme);
  }
}

/// Date picker → unplayed episodes published on or after that day.
Future<void> _playUnplayedSince(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast,
  List<Episode> unplayed, {
  String? theme,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final now = ref.read(clockProvider)();
  final today = DateTime(now.year, now.month, now.day);
  final dates = unplayed.map((e) => e.pubDate).nonNulls.map((d) => d.toLocal());
  final oldest = dates.isEmpty
      ? today
      : dates.reduce((a, b) => a.isBefore(b) ? a : b);
  final firstDate = DateTime(oldest.year, oldest.month, oldest.day);

  final picked = await showDatePicker(
    context: context,
    helpText: l10n.playUnplayedSincePick,
    // Text input (pencil): Samsung's date keyboard has no "." key, so the
    // German date "tt.mm.jjjj" could not be typed – use the full keyboard.
    keyboardType: TextInputType.text,
    initialDate: today,
    firstDate: firstDate.isAfter(today) ? today : firstDate,
    lastDate: today,
  );
  if (picked == null || !context.mounted) return;

  // From the start of the picked day (local time) on.
  final since = DateTime(picked.year, picked.month, picked.day);
  final episodes = await ref
      .read(podcastRepositoryProvider)
      .unplayedEpisodes(
        podcast.id,
        freshOnly: false,
        since: since,
        theme: theme,
      );
  if (!context.mounted) return;
  if (episodes.isEmpty) {
    showInfoSnackBar(
      messenger,
      l10n.playUnplayedSinceNone(
        DateFormat.yMMMMd(l10n.localeName).format(picked),
      ),
    );
    return;
  }
  await playPodcastEpisodes(
    context,
    ref,
    episodes,
    title: l10n.playUnplayedSince,
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
