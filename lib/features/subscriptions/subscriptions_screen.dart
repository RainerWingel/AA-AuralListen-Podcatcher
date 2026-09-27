import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../settings/opml_import_flow.dart';
import 'add_feed_dialog.dart';
import 'refresh_action.dart';

/// Grid of all subscribed podcasts (Castbox-like).
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final id = await showAddFeedDialog(context);
    if (id != null && context.mounted) {
      context.go(Routes.podcast(id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final podcasts = ref.watch(podcastsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSubscriptions),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search),
            onPressed: () => context.go(Routes.search),
          ),
          IconButton(
            tooltip: l10n.addFeedAction,
            icon: const Icon(Icons.add),
            onPressed: () => _add(context),
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
                    FilledButton.icon(
                      onPressed: () => context.go(Routes.search),
                      icon: const Icon(Icons.search),
                      label: Text(l10n.searchHint),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _add(context),
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
            : RefreshIndicator(
                onRefresh: () => refreshAllFeeds(context, ref),
                child: _PodcastGrid(podcasts: podcasts),
              ),
      ),
    );
  }
}

class _PodcastGrid extends StatelessWidget {
  const _PodcastGrid({required this.podcasts});

  final List<Podcast> podcasts;

  static const _spacing = 12.0;
  static const _columns = 3;

  @override
  Widget build(BuildContext context) {
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
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => context.go(Routes.podcast(podcast.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CoverImage(url: podcast.imageUrl, size: tileWidth),
                      if (podcast.lastError != null)
                        const Positioned(
                          right: 4,
                          top: 4,
                          child: Icon(Icons.error, color: Colors.redAccent),
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
