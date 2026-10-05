import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/formatting.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../core/widgets/text_input_dialog.dart';
import '../../data/db/app_database.dart';
import '../../data/playlist_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'playlist_colors.dart';

/// Error message if another playlist already has [name] (case and outer
/// spaces ignored), else null (user wish 2026-10-05).
Future<String? Function(String)> _uniqueName(
  WidgetRef ref,
  AppLocalizations l10n, {
  int? exceptId,
}) async {
  final taken = {
    for (final p in await ref.read(playlistRepositoryProvider).playlists())
      if (p.id != exceptId) p.name.trim().toLowerCase(),
  };
  return (String name) =>
      taken.contains(name.toLowerCase()) ? l10n.playlistNameTaken : null;
}

/// Dialog → new playlist. Returns its id, or null if cancelled.
Future<int?> createPlaylist(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final validate = await _uniqueName(ref, l10n);
  if (!context.mounted) return null;
  final name = await showTextInputDialog(
    context,
    title: l10n.playlistNew,
    confirmLabel: l10n.create,
    validate: validate,
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
  final validate = await _uniqueName(ref, l10n, exceptId: playlist.id);
  if (!context.mounted) return;
  final name = await showTextInputDialog(
    context,
    title: l10n.playlistRename,
    confirmLabel: l10n.save,
    initialValue: playlist.name,
    validate: validate,
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
/// With [episodeId], playlists that already contain it get a ✅.
Future<Playlist?> choosePlaylist(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  int? episodeId,
}) async {
  final l10n = AppLocalizations.of(context);
  final repo = ref.read(playlistRepositoryProvider);
  final playlists = await repo.playlists();
  final containing = episodeId == null
      ? const <int>{}
      : await repo.playlistIdsWith(episodeId);
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
              playlistTintedRow(
                sheetContext,
                p.color,
                child: ListTile(
                  leading: const Icon(Icons.playlist_play),
                  // ✅ right next to the name: the episode is already there.
                  title: Text.rich(
                    TextSpan(
                      text: p.name,
                      children: [
                        if (containing.contains(p.id))
                          const TextSpan(text: ' ✅'),
                      ],
                    ),
                    // Screen readers: "Schon in „X“" instead of the emoji.
                    semanticsLabel: containing.contains(p.id)
                        ? l10n.alreadyInPlaylist(p.name)
                        : null,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(p.id),
                ),
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

/// "Zu Playlist hinzufügen…" for one episode. Choosing a playlist that
/// already contains it asks whether to remove it from there.
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
    episodeId: episodeId,
  );
  if (playlist == null) return;
  final repo = ref.read(playlistRepositoryProvider);
  // Already there (✅ in the sheet): offer to take it out instead.
  if (await repo.positionOf(playlist.id, episodeId) != null) {
    if (!context.mounted) return;
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFromPlaylistTitle),
        content: Text(l10n.removeFromPlaylistBody(playlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.removeFromPlaylistAction),
          ),
        ],
      ),
    );
    if (remove != true) return;
    await repo.remove(playlist.id, episodeId);
    showInfoSnackBar(messenger, l10n.removedFromNamedPlaylist(playlist.name));
    return;
  }
  final added = await repo.add(playlist.id, episodeId);
  showInfoSnackBar(
    messenger,
    added
        ? l10n.addedToPlaylist(playlist.name)
        : l10n.alreadyInPlaylist(playlist.name),
  );
}

/// "Resume": plays the episode last played from [playlist] – or the first
/// one if that episode has left the playlist – and keeps playing the playlist.
Future<void> resumePlaylist(WidgetRef ref, int playlistId) async {
  final episodeId = await ref
      .read(playlistRepositoryProvider)
      .resumeEpisode(playlistId);
  if (episodeId == null) return;
  await ref
      .read(audioHandlerProvider)
      .playEpisode(episodeId, playlistId: playlistId);
}

/// The playlist menu. In the overview ([onPlaylistScreen] false) it offers
/// "Resume" ([canResume]: the playlist has episodes); the sort options only
/// appear on the playlist's own screen. [onDeleted] runs after the playlist
/// was deleted (e.g. leave its screen).
/// Uses the screen [context]: the menu's own context is gone once it closes.
List<PopupMenuEntry<void>> playlistMenuItems(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist, {
  required bool onPlaylistScreen,
  bool canResume = true,
  VoidCallback? onDeleted,
}) {
  final l10n = AppLocalizations.of(context);
  PopupMenuItem<void> item(
    IconData icon,
    String text,
    VoidCallback onTap, {
    bool enabled = true,
  }) => PopupMenuItem(
    onTap: onTap,
    enabled: enabled,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
    ),
  );
  return [
    if (onPlaylistScreen) ...[
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
    ] else
      item(
        Icons.play_circle_outline,
        l10n.playlistResume,
        () => resumePlaylist(ref, playlist.id),
        enabled: canResume,
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
    item(
      Icons.palette_outlined,
      l10n.playlistColor,
      () => choosePlaylistColor(context, ref, playlist),
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
        '${bytes > 0 ? ' ${l10n.playlistDownloadAllSize(formatBytes(bytes, l10n.localeName))}' : ''}'
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
