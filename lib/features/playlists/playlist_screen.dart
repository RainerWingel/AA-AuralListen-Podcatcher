import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/playlist_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_tile.dart';
import 'playlist_actions.dart';
import 'playlist_colors.dart';

/// Episodes of one playlist: drag to reorder, swipe to remove, tap to play
/// (the playlist then continues automatically).
class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({required this.playlistId, super.key});

  final int playlistId;

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    PlaylistEntry entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(playlistRepositoryProvider);
    await repo.remove(playlistId, entry.episode.id);
    if (!context.mounted) return;
    showInfoSnackBar(
      ScaffoldMessenger.of(context),
      l10n.removedFromPlaylist,
      action: SnackBarAction(
        label: l10n.undo,
        // Re-adding appends; restoring the old place is not worth the code.
        onPressed: () => repo.add(playlistId, entry.episode.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlist = ref.watch(playlistProvider(playlistId)).value;
    final entries = ref.watch(playlistEntriesProvider(playlistId));
    final items = entries.value ?? const <PlaylistEntry>[];

    // Category color: app bar in the soft tint, below it fading out downwards.
    final gradient = playlistGradient(
      context,
      playlist?.color,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: playlistBackground(context, playlist?.color),
        title: Text(playlist?.name ?? ''),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: l10n.playlistResume,
              icon: const Icon(Icons.play_circle_outline),
              onPressed: () => resumePlaylist(ref, playlistId),
            ),
          if (playlist != null)
            PopupMenuButton<void>(
              itemBuilder: (_) => playlistMenuItems(
                context,
                ref,
                playlist,
                onPlaylistScreen: true,
                onDeleted: () {
                  if (context.mounted) context.go(Routes.playlists);
                },
              ),
            ),
        ],
      ),
      // Ink (not a plain box) so the episodes' tap ripple stays visible.
      body: Ink(
        decoration: BoxDecoration(gradient: gradient),
        child: entries.isLoading && items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
            ? EmptyState(
                icon: Icons.playlist_add,
                title: l10n.playlistEmpty,
                hint: l10n.playlistEmptyHint,
              )
            : ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) => ref
                    .read(playlistRepositoryProvider)
                    .move(playlistId, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final entry = items[index];
                  return Dismissible(
                    key: ValueKey(entry.episode.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(Icons.playlist_remove),
                    ),
                    onDismissed: (_) => _remove(context, ref, entry),
                    child: Row(
                      children: [
                        Expanded(
                          child: EpisodeTile(
                            episode: entry.episode,
                            podcast: entry.podcast,
                            showPodcastTitle: true,
                            playlistId: playlistId,
                          ),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: Tooltip(
                            message: l10n.dragToReorder,
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 16, 12, 16),
                              child: Icon(Icons.drag_handle),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
