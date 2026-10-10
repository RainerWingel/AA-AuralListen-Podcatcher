import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../audio/audio_providers.dart';
import '../../core/clock.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/feed/rss_parser.dart' show themeDisplayName;
import '../../data/podcast_repository.dart'
    show PodcastRepository, autoPlayedThemesOf;
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../playlists/playlist_actions.dart';

enum _PlayChoice { fresh, since, all, markAll, subscribe }

/// What the three episode entries of [showPodcastPlayMenu] do: add to a
/// chosen playlist and start playing (podcast page, seasons, topics), or
/// only add (long press in the Abos grid, user wish 2026-10-03).
enum PodcastEpisodesAction { play, addToPlaylist }

/// Long press on a subscription tile: "Alle neuen Episoden spielen",
/// "Ungespielte Episoden seit … spielen", "Alle ungespielten Episoden
/// spielen" (docs/playlists.md). With [theme] (long press on a topic in the
/// podcast settings) only that topic's episodes count, with [season] (long
/// press on a season chip on the podcast page) only that season's. With
/// [rating] (Abos tab) the podcast can be rated with 1–5 stars right below
/// the title (user wish 2026-10-05).
Future<void> showPodcastPlayMenu(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast, {
  String? theme,
  int? season,
  PodcastEpisodesAction action = PodcastEpisodesAction.play,
  bool rating = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final play = action == PodcastEpisodesAction.play;
  final repo = ref.read(podcastRepositoryProvider);
  final fresh = await repo.unplayedEpisodes(
    podcast.id,
    freshOnly: true,
    theme: theme,
    season: season,
  );
  final unplayed = await repo.unplayedEpisodes(
    podcast.id,
    freshOnly: false,
    theme: theme,
    season: season,
  );
  final total = await ref
      .read(playbackRepositoryProvider)
      .countEpisodes(podcast.id, theme: theme, season: season);
  // "Mark all as unplayed" only when every affected episode is played.
  final allPlayed = total > 0 && unplayed.isEmpty;
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
        // Less air between the entries, so the stars fit without making
        // the sheet taller (user wish 2026-10-05).
        child: ListTileTheme.merge(
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          minVerticalPadding: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  [
                    podcast.title,
                    if (theme != null) themeDisplayName(theme),
                    if (season != null) l10n.seasonLabel(season),
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                // Provisional podcast: "Abonnieren" right of the name and
                // nothing else – no playlists before subscribing (user wish
                // 2026-10-05).
                trailing: podcast.provisional
                    ? FilledButton(
                        onPressed: () =>
                            Navigator.of(sheetContext)
                                .pop(_PlayChoice.subscribe),
                        child: Text(l10n.subscribeAction),
                      )
                    : null,
              ),
              if (!podcast.provisional) ...[
                if (rating) _RatingStars(podcast: podcast),
                ListTile(
                  leading: const Icon(Icons.fiber_new_outlined),
                  title: Text(
                    play ? l10n.playNewEpisodes : l10n.addNewEpisodesToPlaylist,
                  ),
                  subtitle: Text(l10n.playNewEpisodesHint(fresh.length)),
                  enabled: fresh.isNotEmpty,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PlayChoice.fresh),
                ),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    play
                        ? l10n.playUnplayedSince
                        : l10n.addUnplayedSinceToPlaylist,
                  ),
                  subtitle: Text(l10n.playUnplayedSinceHint),
                  enabled: unplayed.isNotEmpty,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PlayChoice.since),
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(
                    play
                        ? l10n.playUnplayedEpisodes
                        : l10n.addUnplayedEpisodesToPlaylist,
                  ),
                  subtitle: Text(l10n.episodeCount(unplayed.length)),
                  enabled: unplayed.isNotEmpty,
                  onTap: () => Navigator.of(sheetContext).pop(_PlayChoice.all),
                ),
                const Divider(height: 8),
                ListTile(
                  leading: Icon(allPlayed ? Icons.remove_done : Icons.done_all),
                  title: Text(
                    allPlayed ? l10n.markAllUnplayed : l10n.markAllPlayed,
                  ),
                  subtitle: Text(l10n.episodeCount(total)),
                  enabled: total > 0,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PlayChoice.markAll),
                ),
                // Topic menu only: new episodes of it arrive as played
                // (user wish 2026-10-06).
                if (theme != null)
                  _AutoPlayedToggle(podcast: podcast, theme: theme),
              ],
            ],
          ),
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case _PlayChoice.subscribe:
      await subscribeProvisional(context, ref, podcast);
    case _PlayChoice.fresh:
      await playPodcastEpisodes(
        context,
        ref,
        fresh,
        title: play ? l10n.playNewEpisodes : l10n.addNewEpisodesToPlaylist,
        play: play,
      );
    case _PlayChoice.all:
      await playPodcastEpisodes(
        context,
        ref,
        unplayed,
        title: play
            ? l10n.playUnplayedEpisodes
            : l10n.addUnplayedEpisodesToPlaylist,
        play: play,
      );
    case _PlayChoice.since:
      await _playUnplayedSince(
        context,
        ref,
        podcast,
        unplayed,
        theme: theme,
        season: season,
        play: play,
      );
    case _PlayChoice.markAll:
      await _markAll(
        context,
        ref,
        podcast,
        theme: theme,
        season: season,
        played: !allPlayed,
        count: allPlayed ? total : unplayed.length,
      );
  }
}

/// "Alle als gespielt / ungespielt markieren" for the podcast or [theme],
/// after a confirmation with the number of episodes changed.
Future<void> _markAll(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast, {
  required String? theme,
  required int? season,
  required bool played,
  required int count,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(played ? l10n.markAllPlayed : l10n.markAllUnplayed),
      content: Text(
        played
            ? '${l10n.markAllPlayedConfirm(count)}\n\n'
                  '${l10n.markPlayedUntilHint}'
            : '${l10n.markAllUnplayedConfirm(count)}\n\n'
                  '${l10n.markUnplayedSinceHint}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.markAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final playback = ref.read(playbackRepositoryProvider);
  if (played) {
    final marked = await ref
        .read(audioHandlerProvider)
        .markAllPlayed(podcast.id, theme: theme, season: season);
    showInfoSnackBar(messenger, l10n.markPlayedUntilDone(marked));
  } else {
    final marked = await playback.markAllUnplayed(
      podcast.id,
      theme: theme,
      season: season,
    );
    showInfoSnackBar(messenger, l10n.markUnplayedSinceDone(marked));
  }
}

/// Date picker → unplayed episodes published on or after that day.
Future<void> _playUnplayedSince(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast,
  List<Episode> unplayed, {
  String? theme,
  int? season,
  bool play = true,
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
        season: season,
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
    title: play ? l10n.playUnplayedSince : l10n.addUnplayedSinceToPlaylist,
    play: play,
  );
}

/// Adds [episodes] (oldest first) to a chosen playlist – skipping those
/// already in it – and, with [play], starts playing the first of them in
/// that playlist.
Future<void> playPodcastEpisodes(
  BuildContext context,
  WidgetRef ref,
  List<Episode> episodes, {
  required String title,
  bool play = true,
}) async {
  if (episodes.isEmpty) return;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final playlist = await choosePlaylist(context, ref, title: title);
  if (playlist == null) return;

  final added = await ref.read(playlistRepositoryProvider).addAll(playlist.id, [
    for (final e in episodes) e.id,
  ]);
  if (!play) {
    showInfoSnackBar(
      messenger,
      l10n.episodesAddedNoPlay(added.length, playlist.name),
    );
    return;
  }
  await ref
      .read(audioHandlerProvider)
      .playEpisode(episodes.first.id, playlistId: playlist.id);
  showInfoSnackBar(
    messenger,
    l10n.episodesAddedToPlaylist(added.length, playlist.name),
  );
}

/// One of the three play entries of the podcast page's ⋮ menu (user wish
/// 2026-10-03): like the play menu, but without the sheet in between.
enum PodcastPlayEntry { fresh, since, all }

Future<void> playFromPodcastMenu(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast,
  PodcastPlayEntry entry,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final episodes = await ref
      .read(podcastRepositoryProvider)
      .unplayedEpisodes(podcast.id, freshOnly: entry == PodcastPlayEntry.fresh);
  if (!context.mounted) return;
  if (episodes.isEmpty) {
    showInfoSnackBar(
      messenger,
      entry == PodcastPlayEntry.fresh
          ? l10n.playNewEpisodesHint(0)
          : l10n.noUnplayedEpisodes,
    );
    return;
  }
  switch (entry) {
    case PodcastPlayEntry.fresh:
      await playPodcastEpisodes(
        context,
        ref,
        episodes,
        title: l10n.podcastMenuPlayNew,
      );
    case PodcastPlayEntry.all:
      await playPodcastEpisodes(
        context,
        ref,
        episodes,
        title: l10n.podcastMenuPlayUnplayed,
      );
    case PodcastPlayEntry.since:
      await _playUnplayedSince(context, ref, podcast, episodes);
  }
}

/// Five tappable stars; tapping the current rating again removes it.
/// Stored right away, the Abos list re-sorts behind the sheet.
class _RatingStars extends ConsumerStatefulWidget {
  const _RatingStars({required this.podcast});

  final Podcast podcast;

  @override
  ConsumerState<_RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends ConsumerState<_RatingStars> {
  late int _stars = widget.podcast.rating;

  void _rate(int stars) {
    final next = stars == _stars ? 0 : stars;
    setState(() => _stars = next);
    ref.read(podcastRepositoryProvider).setRating(widget.podcast.id, next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final empty = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (var i = 1; i <= PodcastRepository.maxRating; i++)
            IconButton(
              tooltip: i == _stars ? l10n.ratingRemove : l10n.ratingStars(i),
              visualDensity: VisualDensity.compact,
              onPressed: () => _rate(i),
              icon: Icon(
                i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i <= _stars ? Colors.amber.shade600 : empty,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}

/// "Abonnieren" for a provisional podcast (Abos menu, podcast page): from now
/// on downloads, playlists and settings work.
Future<void> subscribeProvisional(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final text = AppLocalizations.of(context).subscribedSnack(podcast.title);
  await ref.read(podcastRepositoryProvider).confirmSubscription(podcast.id);
  showInfoSnackBar(messenger, text);
}

/// "Neue automatisch als gespielt markieren" for one topic: stored at once,
/// the menu stays open.
class _AutoPlayedToggle extends ConsumerStatefulWidget {
  const _AutoPlayedToggle({required this.podcast, required this.theme});

  final Podcast podcast;
  final String theme;

  @override
  ConsumerState<_AutoPlayedToggle> createState() => _AutoPlayedToggleState();
}

class _AutoPlayedToggleState extends ConsumerState<_AutoPlayedToggle> {
  late bool _on = autoPlayedThemesOf(widget.podcast).contains(widget.theme);

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    secondary: const Icon(Icons.playlist_add_check_circle_outlined),
    title: Text(AppLocalizations.of(context).autoMarkNewPlayed),
    value: _on,
    onChanged: (value) {
      final enabled = value ?? false;
      setState(() => _on = enabled);
      ref
          .read(podcastRepositoryProvider)
          .setAutoPlayedTheme(
            widget.podcast.id,
            widget.theme,
            enabled: enabled,
          );
    },
  );
}
