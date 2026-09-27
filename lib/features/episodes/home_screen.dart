import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../subscriptions/refresh_action.dart';
import 'episode_tile.dart';

/// Newest episodes across all subscriptions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final episodes = ref.watch(latestEpisodesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: RefreshIndicator(
        onRefresh: () => refreshAllFeeds(context, ref),
        child: episodes.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(l10n.loadError)),
          data: (items) => items.isEmpty
              ? EmptyState(
                  icon: Icons.headphones,
                  title: l10n.homeEmpty,
                  hint: l10n.homeEmptyHint,
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) => EpisodeTile(
                    episode: items[index].episode,
                    podcast: items[index].podcast,
                    showPodcastTitle: true,
                  ),
                ),
        ),
      ),
    );
  }
}
