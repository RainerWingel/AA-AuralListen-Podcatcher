import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/storage/download_service.dart';
import '../../l10n/app_localizations.dart';
import '../episodes/episode_description.dart';

/// Details of a download (long press in the Downloads tab, user wish
/// 2026-10-05): full title, podcast, author, dates, size, listening state.
Future<void> showDownloadDetailsSheet(
  BuildContext context,
  DownloadItem item,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  // Above the mini player and navigation bar, below the status bar.
  useRootNavigator: true,
  useSafeArea: true,
  // The sheet's own context is gone once it closes; the notes sheet that
  // follows opens from the Downloads tab's context.
  builder: (_) => _DownloadDetails(initial: item, outerContext: context),
);

class _DownloadDetails extends ConsumerWidget {
  const _DownloadDetails({required this.initial, required this.outerContext});

  final DownloadItem initial;
  final BuildContext outerContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final episodeId = initial.download.episodeId;
    // Live: the state changes while a download runs or waits.
    final item =
        ref
            .watch(downloadItemsProvider)
            .value
            ?.where((i) => i.download.episodeId == episodeId)
            .firstOrNull ??
        initial;
    final (:download, :episode, :podcast) = item;
    final progress = ref.watch(
      downloadProgressProvider.select((p) => p.value?[episodeId]),
    );
    final number = ref.watch(
      episodeNumbersProvider(podcast.id).select((n) => n.value?[episodeId]),
    );
    String date(DateTime d) => DateFormat.yMMMMd(locale).format(d.toLocal());
    String dateTime(DateTime d) =>
        '${date(d)}, ${DateFormat.Hm(locale).format(d.toLocal())}';

    final status = switch (download.state) {
      DownloadState.done => l10n.downloadDone,
      DownloadState.failed => l10n.downloadFailed,
      DownloadState.queued =>
        download.wifiOnly ? l10n.downloadWifiWaiting : l10n.downloadQueued,
      DownloadState.running =>
        progress != null ? '${(progress * 100).round()} %' : '…',
    };
    final listening = switch (episode.status) {
      EpisodeStatus.newEpisode => l10n.episodeNew,
      EpisodeStatus.inProgress => l10n.detailsInProgress(
        formatClock(Duration(milliseconds: episode.positionMs)),
      ),
      EpisodeStatus.played => switch (episode.playedAt) {
        final at? => l10n.detailsPlayedAt(date(at)),
        null => l10n.episodePlayed,
      },
    };
    final rows = <(String, String)>[
      if (podcast.author case final author? when author.isNotEmpty)
        (l10n.detailsAuthor, author),
      if (number != null) (l10n.detailsEpisode, number),
      if (episode.pubDate case final pub?) (l10n.detailsPublished, date(pub)),
      if (episode.durationMs case final ms?)
        (
          l10n.detailsDuration,
          formatEpisodeDuration(l10n, Duration(milliseconds: ms)),
        ),
      (l10n.detailsStatus, status),
      if (download.state == DownloadState.done) ...[
        if (download.sizeBytes case final bytes?)
          (l10n.detailsSize, formatBytes(bytes, locale)),
        if (download.completedAt case final at?)
          (l10n.detailsDownloadedAt, dateTime(at)),
      ],
      (l10n.detailsListening, listening),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: ListView(
        shrinkWrap: true,
        // The last line stays above Android's navigation buttons.
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          16 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoverImage(url: episode.imageUrl ?? podcast.imageUrl, size: 72),
              const SizedBox(width: 16),
              Expanded(
                // Full title, no ellipsis; selectable for copying.
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: episode.title,
                        style: theme.textTheme.titleMedium,
                      ),
                      TextSpan(
                        text: '\n${podcast.title}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Text(value)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.notes),
              label: Text(l10n.episodeDescription),
              onPressed: () {
                Navigator.of(context).pop();
                showEpisodeDescriptionSheet(
                  outerContext,
                  episodeId: episodeId,
                  title: episode.title,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
