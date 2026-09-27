import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/info_snack_bar.dart';
import '../../core/widgets/text_input_dialog.dart';
import '../../data/db/app_database.dart';
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

/// "Zu Playlist hinzufügen…": with one playlist it adds directly, otherwise
/// a sheet lets the user choose (or create a new one).
Future<void> addToPlaylist(
  BuildContext context,
  WidgetRef ref,
  int episodeId,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final repo = ref.read(playlistRepositoryProvider);
  final playlists = await repo.playlists();
  if (!context.mounted) return;

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
                l10n.addToPlaylist,
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
  if (chosen == null || chosen < 0) return;

  final added = await repo.add(chosen, episodeId);
  final name = (await repo.playlists()).firstWhere((p) => p.id == chosen).name;
  showInfoSnackBar(
    messenger,
    added ? l10n.addedToPlaylist(name) : l10n.alreadyInPlaylist(name),
  );
}
