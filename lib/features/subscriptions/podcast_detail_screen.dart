import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_tile.dart';
import 'mark_played_until.dart';
import 'podcast_settings_sheet.dart';

/// Podcast header plus its episode list.
class PodcastDetailScreen extends ConsumerWidget {
  const PodcastDetailScreen({required this.podcastId, super.key});

  final int podcastId;

  Future<void> _unsubscribe(
    BuildContext context,
    WidgetRef ref,
    Podcast podcast,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsubscribeConfirmTitle),
        content: Text(l10n.unsubscribeConfirmBody(podcast.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.unsubscribe),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final podcast = ref.watch(podcastProvider(podcastId));
    final episodes = ref.watch(podcastEpisodesProvider(podcastId));

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
        final items = episodes.value ?? const <Episode>[];
        return Scaffold(
          appBar: AppBar(
            title: Text(podcast.title),
            actions: [
              PopupMenuButton<void>(
                // Use the screen context: the menu's own context goes away on close.
                itemBuilder: (_) => [
                  PopupMenuItem(
                    onTap: () => showPodcastSettingsSheet(context, podcast.id),
                    child: Text(l10n.podcastSettings),
                  ),
                  PopupMenuItem(
                    onTap: () =>
                        markPlayedUntilFlow(context, ref, podcast, items),
                    child: Text(l10n.markPlayedUntil),
                  ),
                  PopupMenuItem(
                    onTap: () => _unsubscribe(context, ref, podcast),
                    child: Text(l10n.unsubscribe),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(ref, podcast),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + 1,
              itemBuilder: (context, index) => index == 0
                  ? _Header(podcast: podcast, episodeCount: items.length)
                  : EpisodeTile(episode: items[index - 1], podcast: podcast),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.podcast, required this.episodeCount});

  final Podcast podcast;
  final int episodeCount;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
