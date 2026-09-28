import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/formatting.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/playlist_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'playlist_actions.dart';

/// All playlists; drag to reorder, tap to open.
class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlists = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPlaylists),
        actions: [
          IconButton(
            tooltip: l10n.playlistNew,
            icon: const Icon(Icons.playlist_add),
            onPressed: () => createPlaylist(context, ref),
          ),
        ],
      ),
      body: playlists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.loadError)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.playlist_play,
                title: l10n.playlistsEmpty,
                action: FilledButton.icon(
                  onPressed: () => createPlaylist(context, ref),
                  icon: const Icon(Icons.playlist_add),
                  label: Text(l10n.playlistNew),
                ),
              )
            : ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) {
                  final ids = items.map((i) => i.playlist.id).toList();
                  ids.insert(newIndex, ids.removeAt(oldIndex));
                  ref.read(playlistRepositoryProvider).reorderPlaylists(ids);
                },
                itemBuilder: (context, index) => _PlaylistTile(
                  key: ValueKey(items[index].playlist.id),
                  summary: items[index],
                  index: index,
                ),
              ),
      ),
    );
  }
}

class _PlaylistTile extends ConsumerWidget {
  const _PlaylistTile({required this.summary, required this.index, super.key});

  final PlaylistSummary summary;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playlist = summary.playlist;
    final duration = summary.duration > Duration.zero
        ? ' · ${formatEpisodeDuration(l10n, summary.duration)}'
        : '';
    return ListTile(
      leading: const Icon(Icons.playlist_play, size: 32),
      title: Text(playlist.name),
      subtitle: Text(l10n.playlistSummary(summary.count, duration)),
      onTap: () => context.go(Routes.playlist(playlist.id)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PopupMenuButton<void>(
            // Screen context: the menu's own context goes away on close.
            itemBuilder: (_) => playlistMenuItems(context, ref, playlist),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Tooltip(
              message: l10n.dragToReorder,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
