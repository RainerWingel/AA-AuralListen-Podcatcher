import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../player/chapters_and_bookmarks.dart';

/// All bookmarks, newest first. Tap plays the episode from that position.
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(allBookmarksProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookmarks)),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.loadError)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.bookmark_outline,
                title: l10n.bookmarksEmpty,
                hint: l10n.bookmarksEmptyHint,
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final e = items[index];
                  return BookmarkTile(
                    bookmark: e.bookmark,
                    leading: CoverImage(
                      url: e.episode.imageUrl ?? e.podcast.imageUrl,
                      size: 48,
                    ),
                    subtitle: e.episode.title,
                    onTap: () => ref
                        .read(audioHandlerProvider)
                        .playEpisode(
                          e.episode.id,
                          startAt: Duration(
                            milliseconds: e.bookmark.positionMs,
                          ),
                        ),
                  );
                },
              ),
      ),
    );
  }
}
