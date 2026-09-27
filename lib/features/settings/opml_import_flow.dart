import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/feed/opml.dart';
import '../../data/feed/rss_parser.dart' show FeedFormatException;
import '../../data/opml_importer.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// OPML files are small; anything larger is certainly not a subscription list.
const _maxOpmlBytes = 5 * 1024 * 1024;

/// Pick file → confirm → import with progress → show summary.
Future<void> runOpmlImport(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  void showError(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  final List<OpmlFeed> feeds;
  try {
    // FileType.any: Android does not know a MIME type for .opml.
    final files = await FilePicker.pickFiles();
    if (files.isEmpty) return;
    final file = files.single;
    if ((await file.length() ?? 0) > _maxOpmlBytes) {
      showError(l10n.opmlTooLarge);
      return;
    }
    feeds = parseOpml(
      utf8.decode(await file.readAsBytes(), allowMalformed: true),
    );
  } on FeedFormatException {
    showError(l10n.opmlInvalid);
    return;
  } finally {
    // The picker copies the file into the app cache – remove it (docs/eviction.md).
    await FilePicker.clearTemporaryFiles();
  }

  if (feeds.isEmpty) {
    showError(l10n.opmlEmpty);
    return;
  }
  if (!context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.opmlConfirmTitle),
      content: Text(l10n.opmlConfirmBody(feeds.length)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.opmlImportAction),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final progress = ValueNotifier<int>(0);
  final navigator = Navigator.of(context);
  final OpmlImportResult result;
  try {
    // Non-dismissible progress dialog; closed below when the import is done.
    final dialog = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: ValueListenableBuilder<int>(
            valueListenable: progress,
            builder: (context, done, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: done / feeds.length),
                const SizedBox(height: 16),
                Text(l10n.opmlProgress(done, feeds.length)),
              ],
            ),
          ),
        ),
      ),
    );
    result = await ref
        .read(opmlImporterProvider)
        .import(feeds, onProgress: (done, _) => progress.value = done);
    navigator.pop();
    await dialog;
  } finally {
    progress.dispose();
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.opmlResultTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.opmlResultBody(
                result.added,
                result.alreadySubscribed,
                result.failed.length,
              ),
            ),
            if (result.failed.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l10n.opmlResultFailedList),
              for (final name in result.failed) Text('• $name'),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}
