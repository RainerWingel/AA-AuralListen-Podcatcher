import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/text_utils.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_tile.dart';
import '../settings/opml_import_flow.dart';
import 'add_feed_dialog.dart';
import 'play_podcast_episodes.dart';
import 'refresh_action.dart';

/// Grid of all subscribed podcasts (Castbox-like). The search button here
/// searches only the subscriptions – podcasts and their episodes, locally;
/// the directory search for new podcasts is on the home screen.
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final id = await showAddFeedDialog(context);
    if (id != null && mounted) {
      context.go(Routes.podcast(id));
    }
  }

  void _closeSearch() => setState(() {
    _searching = false;
    _query = '';
    _searchController.clear();
  });

  AppBar _searchBar(AppLocalizations l10n) => AppBar(
    leading: IconButton(
      tooltip: l10n.subsSearchClose,
      icon: const Icon(Icons.arrow_back),
      onPressed: _closeSearch,
    ),
    title: TextField(
      controller: _searchController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.subsSearchHint,
        border: InputBorder.none,
      ),
      onChanged: (text) => setState(() => _query = text.trim()),
    ),
    actions: [
      if (_query.isNotEmpty)
        IconButton(
          tooltip: l10n.searchClear,
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _query = '';
            _searchController.clear();
          }),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final podcasts = ref.watch(podcastsProvider);

    return PopScope(
      // Android back closes the search first.
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        appBar: _searching
            ? _searchBar(l10n)
            : AppBar(
                title: Text(l10n.navSubscriptions),
                actions: [
                  if (podcasts.value?.isNotEmpty ?? false)
                    IconButton(
                      tooltip: l10n.subsSearchHint,
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() => _searching = true),
                    ),
                  IconButton(
                    tooltip: l10n.addFeedAction,
                    icon: const Icon(Icons.add),
                    onPressed: _add,
                  ),
                ],
              ),
        body: podcasts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(l10n.loadError)),
          data: (podcasts) => podcasts.isEmpty
              ? EmptyState(
                  icon: Icons.podcasts,
                  title: l10n.subscriptionsEmpty,
                  hint: l10n.subscriptionsEmptyHint,
                  action: Column(
                    children: [
                      // No subscriptions yet: the directory search helps.
                      FilledButton.icon(
                        onPressed: () => context.go(Routes.search),
                        icon: const Icon(Icons.search),
                        label: Text(l10n.searchHint),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _add,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addFeedAction),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => runOpmlImport(context, ref),
                        icon: const Icon(Icons.file_upload_outlined),
                        label: Text(l10n.opmlImport),
                      ),
                    ],
                  ),
                )
              : _searching && _query.isNotEmpty
              ? _SubscriptionSearchResults(podcasts: podcasts, query: _query)
              : RefreshIndicator(
                  onRefresh: () => refreshAllFeeds(context, ref),
                  child: _PodcastGrid(podcasts: podcasts),
                ),
        ),
      ),
    );
  }
}

/// Podcast name or author contains [query] (case and umlauts ignored).
bool podcastMatches(Podcast podcast, String query) {
  final q = foldForSearch(query.trim());
  return foldForSearch(podcast.title).contains(q) ||
      foldForSearch(podcast.author ?? '').contains(q);
}

/// Search results in the Abos tab: matching podcasts, then episodes.
class _SubscriptionSearchResults extends ConsumerWidget {
  const _SubscriptionSearchResults({
    required this.podcasts,
    required this.query,
  });

  final List<Podcast> podcasts;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final matching = [
      for (final p in podcasts)
        if (podcastMatches(p, query)) p,
    ];
    final episodes = ref.watch(subscriptionEpisodeSearchProvider(query));
    // Keep the last results while the next keystroke's query runs.
    final found = episodes.value ?? const <EpisodeWithPodcast>[];

    if (matching.isEmpty && found.isEmpty && !episodes.isLoading) {
      return EmptyState(
        icon: Icons.search_off,
        title: l10n.subsSearchNothing,
        hint: l10n.subsSearchNothingHint,
      );
    }
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (matching.isNotEmpty) ...[
          header(l10n.subsSearchPodcasts),
          for (final podcast in matching)
            ListTile(
              leading: CoverImage(url: podcast.imageUrl, size: 48),
              title: Text(podcast.title),
              subtitle: podcast.author == null ? null : Text(podcast.author!),
              onTap: () => context.go(Routes.podcast(podcast.id)),
              onLongPress: () => showPodcastPlayMenu(
                context,
                ref,
                podcast,
                // In the Abos grid only into a playlist (user wish 2026-10-03).
                action: PodcastEpisodesAction.addToPlaylist,
                rating: true,
              ),
            ),
        ],
        if (found.isNotEmpty) ...[
          header(l10n.subsSearchEpisodes),
          for (final e in found)
            EpisodeTile(
              episode: e.episode,
              podcast: e.podcast,
              showPodcastTitle: true,
            ),
        ],
      ],
    );
  }
}

class _PodcastGrid extends ConsumerWidget {
  const _PodcastGrid({required this.podcasts});

  final List<Podcast> podcasts;

  static const _spacing = 12.0;
  static const _columns = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unplayed = ref.watch(unplayedCountsProvider).value ?? const {};
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth =
            (constraints.maxWidth - _spacing * (_columns + 1)) / _columns;
        return GridView.builder(
          padding: const EdgeInsets.all(_spacing),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            // Cover plus two lines of title.
            mainAxisExtent: tileWidth + 44,
          ),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            final count = unplayed[podcast.id] ?? 0;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.go(Routes.podcast(podcast.id)),
              onLongPress: () => showPodcastPlayMenu(
                context,
                ref,
                podcast,
                // In the Abos grid only into a playlist (user wish 2026-10-03).
                action: PodcastEpisodesAction.addToPlaylist,
                rating: true,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CoverImage(url: podcast.imageUrl, size: tileWidth),
                      // Top left, so it never hides the badge.
                      if (podcast.lastError != null)
                        const Positioned(
                          left: 4,
                          top: 4,
                          child: Icon(Icons.error, color: Colors.redAccent),
                        ),
                      if (count > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Semantics(
                            label: l10n.unplayedCount(count),
                            excludeSemantics: true,
                            // Shows "99+" above 99.
                            child: Badge.count(
                              count: count,
                              maxCount: 99,
                              // Clearly red in light and dark theme (the
                              // dark error colour is a pale pink).
                              backgroundColor: Colors.red.shade700,
                              textColor: Colors.white,
                              largeSize: 22,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    podcast.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
