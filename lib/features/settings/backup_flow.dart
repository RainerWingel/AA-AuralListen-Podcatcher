import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../audio/audio_providers.dart';
import '../../core/clock.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/backup/backup_service.dart';
import '../../data/feed/opml.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Lets the user choose where to save [bytes] (Android "Save as" dialog).
/// Returns false if cancelled.
Future<bool> _saveAs(String fileName, Uint8List bytes, String mimeType) async =>
    await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
    ) !=
    null;

String _today(DateTime now) => DateFormat('yyyy-MM-dd').format(now);

Future<void> exportOpml(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final now = ref.read(clockProvider)();
  final podcasts = await ref
      .read(podcastRepositoryProvider)
      .watchPodcasts()
      .first;
  final xml = buildOpml(podcasts, created: now);
  try {
    if (await _saveAs(
      'AA-PodcastGuru-Abos-${_today(now)}.opml',
      Uint8List.fromList(utf8.encode(xml)),
      'text/x-opml',
    )) {
      showInfoSnackBar(messenger, l10n.opmlExported);
    }
  } on Exception {
    showInfoSnackBar(messenger, l10n.saveFailed);
  }
}

Future<void> createBackup(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final backup = ref.read(backupServiceProvider);
  try {
    final bytes = await backup.createBackup();
    if (await _saveAs(backup.suggestedFileName(), bytes, 'application/zip')) {
      showInfoSnackBar(messenger, l10n.backupCreated);
    }
  } on Exception {
    showInfoSnackBar(messenger, l10n.saveFailed);
  }
}

/// Pick → check → confirm (with contents) → replace all data.
Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final backup = ref.read(backupServiceProvider);

  final BackupPreview preview;
  try {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return;
    final file = files.single;
    if ((await file.length() ?? 0) > BackupService.maxBackupBytes) {
      showInfoSnackBar(messenger, l10n.backupInvalid);
      return;
    }
    preview = await backup.inspect(await file.readAsBytes());
  } on BackupFormatException catch (e) {
    showInfoSnackBar(
      messenger,
      e.message.contains('newer') ? l10n.backupTooNew : l10n.backupInvalid,
    );
    return;
  } finally {
    // The picker copied the file into the app cache (docs/eviction.md).
    await FilePicker.clearTemporaryFiles();
  }

  if (!context.mounted) {
    await preview.discard();
    return;
  }
  final date = preview.createdAt == null
      ? '–'
      : DateFormat.yMMMMd('de').add_Hm().format(preview.createdAt!);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.backupConfirmTitle),
      content: Text(
        l10n.backupConfirmBody(
          date,
          preview.podcasts,
          preview.episodes,
          preview.playlists,
          preview.bookmarks,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.backupRestoreAction),
        ),
      ],
    ),
  );
  if (confirmed != true) {
    await preview.discard();
    return;
  }

  final handler = ref.read(audioHandlerProvider);
  final downloads = ref.read(downloadServiceProvider);
  await handler.stop();
  await downloads.cancelAll();
  await backup.restore(preview);
  // Download rows are gone → maintenance deletes the now orphaned files.
  await downloads.runMaintenance();
  await handler.resetAfterRestore();
  showInfoSnackBar(messenger, l10n.backupRestored);
}
