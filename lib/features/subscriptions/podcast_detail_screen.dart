import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/app_platform.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_tile.dart';
import 'mark_played_until.dart';
import 'play_podcast_episodes.dart';
import 'podcast_settings_sheet.dart';

/// Podcast header plus its episode list; podcasts with seasons get season
/// chips to filter the list (docs/ui-ux.md "Staffeln").
class PodcastDetailScreen extends ConsumerStatefulWidget {
  const PodcastDetailScreen({required this.podcastId, super.key});

  final int podcastId;

  @override
  ConsumerState<PodcastDetailScreen> createState() =>
      _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends ConsumerState<PodcastDetailScreen> {
  /// Selected season chip; null = all episodes.
  int? _season;

  int get podcastId => widget.podcastId;

  /// "Deabonnieren" (button in the header), or "Entfernen" (⋮) for a
  /// provisional podcast – both delete the podcast with its episodes.
  Future<void> _unsubscribe(
    BuildContext context,
    WidgetRef ref,
    Podcast podcast,
  ) async {
    final l10n = AppLocalizations.of(context);
    final remove = podcast.provisional;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          remove
              ? l10n.podcastRemoveConfirmTitle
              : l10n.unsubscribeConfirmTitle,
        ),
        content: Text(l10n.unsubscribeConfirmBody(podcast.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(remove ? l10n.podcastRemove : l10n.unsubscribe),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Leave the screen first so it does not show a half-deleted podcast.
    context.go(Routes.subscriptions);
    await ref.read(podcastRepositoryProvider).unsubscribe(podcast.id);
  }

  Future<void> _refresh(WidgetRef ref, Podcast podcast) =>
      ref.read(podcastRepositoryProvider).refreshPodcast(podcast);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final podcast = ref.watch(podcastProvider(podcastId));
    final episodes = ref.watch(podcastEpisodesProvider(podcastId));
    final seasons =
        ref.watch(podcastSeasonsProvider(podcastId)).value ?? const <int>[];
    // A season that vanished (feed changed) falls back to "all".
    final season = seasons.contains(_season) ? _season : null;

    return podcast.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.loadError)),
      ),
      data: (podcast) {
        if (podcast == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.podcastNotFound)),
          );
        }
        final all = episodes.value ?? const <Episode>[];
        final items = season == null
            ? all
            : all.where((e) => e.season == season).toList();
        final extra = seasons.isEmpty ? 1 : 2; // header (+ season chips)
        return Scaffold(
          appBar: AppBar(
            title: Text(podcast.title),
            actions: [
              PopupMenuButton<void>(
                // Use the screen context: the menu's own context goes away on close.
                // Provisional podcast: only "Entfernen" (user wish 2026-10-05).
                itemBuilder: (_) => [
                  if (podcast.provisional)
                    PopupMenuItem(
                      onTap: () => _unsubscribe(context, ref, podcast),
                      child: Text(l10n.podcastRemove),
                    )
                  else ...[
                    PopupMenuItem(
                      onTap: () =>
                          showPodcastSettingsSheet(context, podcast.id),
                      child: Text(l10n.podcastSettings),
                    ),
                    PopupMenuItem(
                      onTap: () => playFromPodcastMenu(
                        context,
                        ref,
                        podcast,
                        PodcastPlayEntry.fresh,
                      ),
                      child: Text(l10n.podcastMenuPlayNew),
                    ),
                    PopupMenuItem(
                      onTap: () => playFromPodcastMenu(
                        context,
                        ref,
                        podcast,
                        PodcastPlayEntry.since,
                      ),
                      child: Text(l10n.podcastMenuPlaySince),
                    ),
                    PopupMenuItem(
                      onTap: () => playFromPodcastMenu(
                        context,
                        ref,
                        podcast,
                        PodcastPlayEntry.all,
                      ),
                      child: Text(l10n.podcastMenuPlayUnplayed),
                    ),
                    PopupMenuItem(
                      onTap: () =>
                          markPlayedUntilFlow(context, ref, podcast, all),
                      child: Text(l10n.markPlayedUntil),
                    ),
                    PopupMenuItem(
                      onTap: () =>
                          markUnplayedSinceFlow(context, ref, podcast, all),
                      child: Text(l10n.markUnplayedSince),
                    ),
                    // "Abo kündigen" is the "Deabonnieren" button in the
                    // header now (user wish 2026-10-05).
                  ],
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(ref, podcast),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + extra,
              itemBuilder: (context, index) => switch (index) {
                0 => _Header(
                  podcast: podcast,
                  episodeCount: all.length,
                  onUnsubscribe: () => _unsubscribe(context, ref, podcast),
                ),
                1 when extra == 2 => _SeasonChips(
                  podcast: podcast,
                  seasons: seasons,
                  selected: season,
                  onSelected: (s) => setState(() => _season = s),
                ),
                _ => EpisodeTile(
                  episode: items[index - extra],
                  podcast: podcast,
                ),
              },
            ),
          ),
        );
      },
    );
  }
}

/// "Alle · Staffel 1 · Staffel 2 …": tap filters the list, long press opens
/// the play menu for that season (like topics in the podcast settings).
class _SeasonChips extends ConsumerWidget {
  const _SeasonChips({
    required this.podcast,
    required this.seasons,
    required this.selected,
    required this.onSelected,
  });

  final Podcast podcast;
  final List<int> seasons;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: Text(l10n.seasonAll),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            for (final s in seasons) ...[
              const SizedBox(width: 8),
              GestureDetector(
                // Provisional: no playlists yet, so no play menu.
                onLongPress: podcast.provisional
                    ? null
                    : () =>
                          showPodcastPlayMenu(context, ref, podcast, season: s),
                child: ChoiceChip(
                  label: Text(l10n.seasonLabel(s)),
                  selected: selected == s,
                  onSelected: (_) => onSelected(s),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.podcast,
    required this.episodeCount,
    required this.onUnsubscribe,
  });

  final Podcast podcast;
  final int episodeCount;
  final VoidCallback onUnsubscribe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(url: podcast.imageUrl, size: 120),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(podcast.title, style: theme.textTheme.titleLarge),
                    if (podcast.author case final author?) ...[
                      const SizedBox(height: 4),
                      Text(author, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      l10n.episodeCount(episodeCount),
                      style: theme.textTheme.bodySmall,
                    ),
                    // "Abonnieren" (same as in the Abos menu) or, in the
                    // same place, "Deabonnieren" (user wish 2026-10-05).
                    const SizedBox(height: 8),
                    if (podcast.provisional)
                      FilledButton(
                        onPressed: () =>
                            subscribeProvisional(context, ref, podcast),
                        child: Text(l10n.subscribeAction),
                      )
                    else
                      OutlinedButton(
                        onPressed: onUnsubscribe,
                        child: Text(l10n.unsubscribe),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (podcast.lastError != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.podcastRefreshError,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
          if (podcast.description case final description?) ...[
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (podcast.websiteUrl != null || podcast.fundingUrl != null) ...[
            const SizedBox(height: 4),
            _PodcastLinks(podcast: podcast),
          ],
        ],
      ),
    );
  }
}

/// Website and "support" link (`podcast:funding`) from the feed, opened in
/// the browser (user wish 2026-10-03).
class _PodcastLinks extends ConsumerWidget {
  const _PodcastLinks({required this.podcast});

  final Podcast podcast;

  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).infoLinkFailed;
    if (!await ref.read(appPlatformProvider).openUrl(url)) {
      showInfoSnackBar(messenger, failed);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    Widget link(IconData icon, String label, String url) => TextButton.icon(
      onPressed: () => _open(context, ref, url),
      icon: Icon(icon, size: 18),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    return Wrap(
      spacing: 8,
      children: [
        if (podcast.websiteUrl case final url?)
          // The host is more telling than "Website", e.g. "freakshow.fm".
          link(
            Icons.language,
            Uri.tryParse(url)?.host.replaceFirst(RegExp(r'^www\.'), '') ??
                l10n.podcastWebsite,
            url,
          ),
        if (podcast.fundingUrl case final url?)
          link(
            Icons.favorite_outline,
            podcast.fundingLabel ?? l10n.podcastSupport,
            url,
          ),
      ],
    );
  }
}
