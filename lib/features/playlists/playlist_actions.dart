import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../core/widgets/text_input_dialog.dart';
import '../../data/db/app_database.dart';
import '../../data/playlist_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Dialog → new playlist. Returns its id, or null if cancelled.
Future<int?> createPlaylist(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final name = await showTextInputDialog(
    context,
    title: l10n.playlistNew,
    confirmLabel: l10n.create,
  );
  if (name == null) return null;
  return ref.read(playlistRepositoryProvider).create(name);
}

Future<void> renamePlaylist(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final l10n = AppLocalizations.of(context);
  final name = await showTextInputDialog(
    context,
    title: l10n.playlistRename,
    confirmLabel: l10n.save,
    initialValue: playlist.name,
  );
  if (name != null) {
    await ref.read(playlistRepositoryProvider).rename(playlist.id, name);
  }
}

/// Asks for confirmation; returns true if the playlist was deleted.
Future<bool> deletePlaylist(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.playlistDelete),
      content: Text(l10n.playlistDeleteConfirm(playlist.name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  await ref.read(playlistRepositoryProvider).delete(playlist.id);
  return true;
}

/// Picks a playlist: with exactly one it is used directly, otherwise a
/// sheet lets the user choose (or create a new one). Null = cancelled.
Future<Playlist?> choosePlaylist(
  BuildContext context,
  WidgetRef ref, {
  required String title,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(playlistRepositoryProvider);
  final playlists = await repo.playlists();
  if (!context.mounted) return null;
  int? chosen;
  if (playlists.length == 1) {
    chosen = playlists.single.id;
  } else {
    chosen = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final p in playlists)
              ListTile(
                leading: const Icon(Icons.playlist_play),
                title: Text(p.name),
                onTap: () => Navigator.of(sheetContext).pop(p.id),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.playlistNew),
              onTap: () => Navigator.of(sheetContext).pop(-1),
            ),
          ],
        ),
      ),
    );
    if (chosen == -1 && context.mounted) {
      chosen = await createPlaylist(context, ref);
    }
  }
  if (chosen == null || chosen < 0) return null;
  final id = chosen;
  return (await repo.playlists()).firstWhere((p) => p.id == id);
}

/// "Zu Playlist hinzufügen…" for one episode.
Future<void> addToPlaylist(
  BuildContext context,
  WidgetRef ref,
  int episodeId,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final playlist = await choosePlaylist(
    context,
    ref,
    title: l10n.addToPlaylist,
  );
  if (playlist == null) return;
  final added = await ref
      .read(playlistRepositoryProvider)
      .add(playlist.id, episodeId);
  showInfoSnackBar(
    messenger,
    added
        ? l10n.addedToPlaylist(playlist.name)
        : l10n.alreadyInPlaylist(playlist.name),
  );
}

/// The playlist menu (overview and playlist screen share it). [onDeleted]
/// runs after the playlist was deleted (e.g. leave its screen).
/// Uses the screen [context]: the menu's own context is gone once it closes.
List<PopupMenuEntry<void>> playlistMenuItems(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist, {
  VoidCallback? onDeleted,
}) {
  final l10n = AppLocalizations.of(context);
  PopupMenuItem<void> item(IconData icon, String text, VoidCallback onTap) =>
      PopupMenuItem(
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(text),
        ),
      );
  return [
    item(
      Icons.arrow_upward,
      l10n.playlistSortDateAscending,
      () => sortPlaylist(context, ref, playlist, PlaylistSort.dateAscending),
    ),
    item(
      Icons.arrow_downward,
      l10n.playlistSortDateDescending,
      () => sortPlaylist(context, ref, playlist, PlaylistSort.dateDescending),
    ),
    item(
      Icons.arrow_upward,
      l10n.playlistSortNameAscending,
      () => sortPlaylist(context, ref, playlist, PlaylistSort.nameAscending),
    ),
    item(
      Icons.download_for_offline_outlined,
      l10n.playlistDownloadAll,
      () => downloadWholePlaylist(context, ref, playlist),
    ),
    const PopupMenuDivider(),
    item(
      Icons.edit_outlined,
      l10n.playlistRename,
      () => renamePlaylist(context, ref, playlist),
    ),
    item(Icons.delete_outline, l10n.playlistDelete, () async {
      if (await deletePlaylist(context, ref, playlist)) onDeleted?.call();
    }),
  ];
}

Future<void> sortPlaylist(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
  PlaylistSort order,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await ref.read(playlistRepositoryProvider).sort(playlist.id, order);
  showInfoSnackBar(messenger, switch (order) {
    PlaylistSort.dateAscending => l10n.playlistSortedDateAscending(
      playlist.name,
    ),
    PlaylistSort.dateDescending => l10n.playlistSortedDateDescending(
      playlist.name,
    ),
    PlaylistSort.nameAscending => l10n.playlistSortedName(playlist.name),
  });
}

/// "Alles downloaden": asks first (count, approximate size), then queues
/// every episode of the playlist that is not downloaded or queued yet.
Future<void> downloadWholePlaylist(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final downloads = ref.read(downloadServiceProvider);
  final entries = await ref
      .read(playlistRepositoryProvider)
      .entries(playlist.id);
  final states = await downloads.states();
  // Not downloaded yet, or failed before (retry).
  final missing = [
    for (final e in entries)
      if (states[e.episode.id]?.state case null || DownloadState.failed)
        e.episode,
  ];
  if (!context.mounted) return;
  if (missing.isEmpty) {
    showInfoSnackBar(messenger, l10n.playlistDownloadAllNone);
    return;
  }

  final bytes = missing.fold<int>(0, (sum, e) => sum + (e.audioSizeBytes ?? 0));
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.playlistDownloadAll),
      content: Text(
        '${l10n.playlistDownloadAllConfirm(missing.length, playlist.name)}'
        '${bytes > 0 ? ' ${l10n.playlistDownloadAllSize(formatBytes(bytes))}' : ''}'
        '\n\n${l10n.playlistDownloadAllHint}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.download),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  for (final e in missing) {
    await downloads.download(e.id);
  }
  showInfoSnackBar(messenger, l10n.playlistDownloadAllStarted(missing.length));
}
