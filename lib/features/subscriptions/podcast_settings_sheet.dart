import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Choices for "keep the newest N unplayed episodes".
const autoDownloadCounts = <int>[1, 2, 3, 5, 10];

Future<void> showPodcastSettingsSheet(BuildContext context, int podcastId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _PodcastSettingsSheet(podcastId: podcastId),
    );

class _PodcastSettingsSheet extends ConsumerWidget {
  const _PodcastSettingsSheet({required this.podcastId});

  final int podcastId;

  Future<void> _update(
    WidgetRef ref, {
    AutoDownloadMode? mode,
    int? max,
    bool? autoDelete,
  }) async {
    await ref
        .read(podcastRepositoryProvider)
        .updatePodcastSettings(
          podcastId,
          autoDownloadMode: mode,
          autoDownloadMaxEpisodes: max,
          autoDeletePlayed: autoDelete,
        );
    // Apply immediately: queue auto-downloads / delete what is now due.
    unawaited(ref.read(downloadServiceProvider).runMaintenance());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final podcast = ref.watch(podcastProvider(podcastId)).value;
    if (podcast == null) return const SizedBox(height: 120);

    final autoOn = podcast.autoDownloadMode != AutoDownloadMode.off;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.podcastSettings, style: theme.textTheme.titleMedium),
            Text(podcast.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            Text(l10n.autoDownload, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<AutoDownloadMode>(
              segments: [
                ButtonSegment(
                  value: AutoDownloadMode.off,
                  label: Text(l10n.autoDownloadOff),
                ),
                ButtonSegment(
                  value: AutoDownloadMode.wifiOnly,
                  label: Text(l10n.autoDownloadWifi),
                ),
                ButtonSegment(
                  value: AutoDownloadMode.always,
                  label: Text(l10n.autoDownloadAlways),
                ),
              ],
              selected: {podcast.autoDownloadMode},
              onSelectionChanged: (v) => _update(ref, mode: v.single),
            ),
            const SizedBox(height: 16),
            Text(l10n.autoDownloadMax, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final n in autoDownloadCounts)
                  ButtonSegment(value: n, label: Text('$n'), enabled: autoOn),
              ],
              selected: {podcast.autoDownloadMaxEpisodes},
              onSelectionChanged: (v) => _update(ref, max: v.single),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.autoDeletePlayed),
              subtitle: Text(l10n.autoDeletePlayedHint),
              value: podcast.autoDeletePlayed,
              onChanged: (v) => _update(ref, autoDelete: v),
            ),
          ],
        ),
      ),
    );
  }
}
