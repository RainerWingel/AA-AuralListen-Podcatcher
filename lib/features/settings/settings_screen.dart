import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

import '../../core/formatting.dart';
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../data/storage/download_service.dart';
import '../../l10n/app_localizations.dart';
import '../downloads/downloads_screen.dart';
import 'opml_import_flow.dart';

/// Selectable storage limits for downloads.
const _gib = 1024 * 1024 * 1024;
const downloadLimitChoices = <int>[
  1 * _gib,
  2 * _gib,
  5 * _gib,
  10 * _gib,
  20 * _gib,
];

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _chooseLimit(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.downloadLimit),
        children: [
          RadioGroup<int>(
            groupValue: current,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              children: [
                for (final limit in downloadLimitChoices)
                  RadioListTile<int>(
                    value: limit,
                    title: Text(formatBytes(limit)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingsKeys.downloadLimitBytes, '$chosen');
    // A smaller limit may require deleting played downloads right away.
    await ref.read(downloadServiceProvider).runMaintenance();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final limit =
        ref.watch(downloadLimitProvider).value ??
        DownloadService.defaultLimitBytes;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsSectionListening),
          ListTile(
            leading: const Icon(Icons.bookmarks_outlined),
            title: Text(l10n.bookmarks),
            onTap: () => context.go(Routes.bookmarks),
          ),
          _SectionHeader(l10n.settingsSectionSubscriptions),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: Text(l10n.opmlImport),
            subtitle: Text(l10n.opmlImportSubtitle),
            onTap: () => runOpmlImport(context, ref),
          ),
          _SectionHeader(l10n.settingsSectionDownloads),
          ListTile(
            leading: const Icon(Icons.sd_storage_outlined),
            title: Text(l10n.downloadLimit),
            subtitle: Text('${formatBytes(limit)} – ${l10n.downloadLimitHint}'),
            isThreeLine: true,
            onTap: () => _chooseLimit(context, ref, limit),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.cleanUpNow),
            onTap: () => cleanUpDownloads(context, ref),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
