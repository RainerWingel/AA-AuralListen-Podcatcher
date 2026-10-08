import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/formatting.dart';
import '../../core/widgets/background_scaffold.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/episode_title.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../core/widgets/squares_background.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/storage/download_service.dart';
import '../../l10n/app_localizations.dart';
import '../playlists/playlist_actions.dart';
import 'download_details_sheet.dart';

/// Runs the eviction rules now and reports the freed space.
Future<void> cleanUpDownloads(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final result = await ref.read(downloadServiceProvider).runMaintenance();
  showInfoSnackBar(
    messenger,
    result.freedBytes > 0
        ? l10n.cleanUpResult(formatBytes(result.freedBytes, l10n.localeName))
        : l10n.cleanUpNothing,
  );
}

/// All downloads: storage usage, running downloads with progress, finished
/// downloads with size. Tap plays, the button cancels/deletes/retries.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(downloadItemsProvider);

    return BackgroundScaffold(
      background: const SquaresBackground(),
      title: Text(l10n.navDownloads),
      actions: [
        IconButton(
          tooltip: l10n.cleanUpNow,
          icon: const Icon(Icons.cleaning_services_outlined),
          onPressed: () => cleanUpDownloads(context, ref),
        ),
      ],
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.loadError)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.download_outlined,
                title: l10n.downloadsEmpty,
                hint: l10n.downloadsEmptyHint,
              )
            : ListView.builder(
                itemCount: items.length + 1,
                itemBuilder: (context, index) => index == 0
                    ? _UsageHeader(items: items)
                    : _DownloadTile(item: items[index - 1]),
              ),
      ),
    );
  }
}

class _UsageHeader extends ConsumerWidget {
  const _UsageHeader({required this.items});

  final List<DownloadItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final limit =
        ref.watch(downloadLimitProvider).value ??
        DownloadService.defaultLimitBytes;
    final used = items
        .where((i) => i.download.state == DownloadState.done)
        .fold(0, (sum, i) => sum + (i.download.sizeBytes ?? 0));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.downloadsUsage(
              formatBytes(used, l10n.localeName),
              formatBytes(limit, l10n.localeName),
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: (used / limit).clamp(0.0, 1.0)),
        ],
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});

  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final service = ref.watch(downloadServiceProvider);
    final download = item.download;
    final episodeId = download.episodeId;
    final progress = ref.watch(
      downloadProgressProvider.select((p) => p.value?[episodeId]),
    );

    final (String status, Widget action) = switch (download.state) {
      DownloadState.done => (
        formatBytes(download.sizeBytes ?? 0, l10n.localeName),
        IconButton(
          tooltip: l10n.downloadDelete,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, service, item.episode),
        ),
      ),
      DownloadState.failed => (
        l10n.downloadFailed,
        IconButton(
          tooltip: l10n.downloadRetry,
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              service.download(episodeId, wifiOnly: download.wifiOnly),
        ),
      ),
      // Waiting is a state of its own, not "0 %" (user report 2026-10-05).
      DownloadState.queued => (
        download.wifiOnly ? l10n.downloadWifiWaiting : l10n.downloadQueued,
        IconButton(
          tooltip: l10n.downloadCancel,
          icon: const Icon(Icons.close),
          onPressed: () => service.cancel(episodeId),
        ),
      ),
      DownloadState.running => (
        progress != null ? '${(progress * 100).round()} %' : '…',
        IconButton(
          tooltip: l10n.downloadCancel,
          icon: const Icon(Icons.close),
          onPressed: () => service.cancel(episodeId),
        ),
      ),
    };

    return ListTile(
      onTap: () => ref.read(audioHandlerProvider).playEpisode(episodeId),
      onLongPress: () => showDownloadDetailsSheet(context, item),
      leading: CoverImage(
        url: item.episode.imageUrl ?? item.podcast.imageUrl,
        size: 56,
      ),
      title: EpisodeTitle(
        item.episode.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.podcast.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(status),
          if (download.state == DownloadState.running)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(value: progress),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (download.state == DownloadState.queued && download.wifiOnly)
            IconButton(
              tooltip: l10n.downloadNowMobile,
              icon: const Icon(Icons.network_cell),
              onPressed: () => service.downloadNow(episodeId),
            ),
          IconButton(
            tooltip: l10n.addToPlaylist,
            icon: const Icon(Icons.playlist_add),
            // One playlist → added directly, otherwise the known chooser.
            onPressed: () => addToPlaylist(context, ref, episodeId),
          ),
          action,
        ],
      ),
    );
  }
}

/// Deleting a downloaded file asks first (user wish 2026-10-05).
Future<void> _confirmDelete(
  BuildContext context,
  DownloadService service,
  Episode episode,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.downloadDelete),
      content: Text(l10n.downloadDeleteConfirm(episode.title)),
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
  if (confirmed == true) await service.delete(episode.id);
}
