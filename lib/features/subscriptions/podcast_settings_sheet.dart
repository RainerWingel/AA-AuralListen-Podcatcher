import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/feed/rss_parser.dart' show themeDisplayName;
import '../../data/podcast_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'change_feed_url_dialog.dart';
import 'play_podcast_episodes.dart';

/// Choices for "keep the newest N unplayed episodes".
const autoDownloadCounts = <int>[1, 2, 3, 5, 10];

/// The settings apply to downloads only when the sheet is closed: switching
/// auto-download on must not start downloads before the number and the
/// topics are chosen (bug 2026-09-30).
Future<void> showPodcastSettingsSheet(
  BuildContext context,
  int podcastId,
) async {
  final downloads = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(downloadServiceProvider);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _PodcastSettingsSheet(podcastId: podcastId),
  );
  // Queue auto-downloads / delete what is now due – once, with the result.
  unawaited(downloads.runMaintenance());
}

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
    // Downloads follow when the sheet is closed (showPodcastSettingsSheet).
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final podcast = ref.watch(podcastProvider(podcastId)).value;
    if (podcast == null) return const SizedBox(height: 120);

    final themes = ref.watch(podcastThemesProvider(podcastId)).value ?? [];
    return SafeArea(
      child: SingleChildScrollView(
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
            Text(l10n.autoDownloadMaxHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final n in autoDownloadCounts)
                  // Choosable before switching auto-download on.
                  ButtonSegment(value: n, label: Text('$n')),
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
            // Only network feeds (e.g. WRINT) have several themes.
            // Editable even while auto-download is off: choose the themes
            // first, then switch it on – otherwise everything starts at once.
            if (themes.length >= 2)
              _ThemeFilter(podcast: podcast, themes: themes),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.rss_feed),
              title: Text(l10n.feedUrlChange),
              subtitle: Text(
                podcast.feedUrl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                if (await showChangeFeedUrlDialog(context, podcast)) {
                  showInfoSnackBar(messenger, l10n.feedUrlChanged);
                  unawaited(ref.read(downloadServiceProvider).runMaintenance());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkbox per theme: which sub-series are auto-downloaded.
class _ThemeFilter extends ConsumerWidget {
  const _ThemeFilter({required this.podcast, required this.themes});

  final Podcast podcast;
  final List<PodcastTheme> themes;

  Future<void> _save(WidgetRef ref, Set<String> selected) async {
    final all = themes.map((t) => t.theme).toSet();
    await ref
        .read(podcastRepositoryProvider)
        // Everything selected is stored as "all" (null), so it stays open for
        // episodes whose theme is not known yet.
        .setAutoDownloadThemes(
          podcast.id,
          selected.containsAll(all) ? null : selected,
        );
    // Downloads follow when the sheet is closed (showPodcastSettingsSheet).
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();
    final filter = autoDownloadThemesOf(podcast);
    final selected = filter ?? themes.map((t) => t.theme).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.autoDownloadThemes,
                style: theme.textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () => _save(ref, themes.map((t) => t.theme).toSet()),
              child: Text(l10n.selectAll),
            ),
            TextButton(
              onPressed: () => _save(ref, {}),
              child: Text(l10n.selectNone),
            ),
          ],
        ),
        Text(l10n.autoDownloadThemesHint, style: theme.textTheme.bodySmall),
        for (final t in themes)
          // Long press: play this topic's episodes (same menu as on a
          // subscription, limited to the topic).
          GestureDetector(
            onLongPress: () =>
                showPodcastPlayMenu(context, ref, podcast, theme: t.theme),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: selected.contains(t.theme),
              onChanged: (checked) => _save(
                ref,
                checked == true
                    ? {...selected, t.theme}
                    : ({...selected}..remove(t.theme)),
              ),
              secondary: CoverImage(
                url: t.imageUrl ?? podcast.imageUrl,
                size: 48,
              ),
              title: Text(themeDisplayName(t.theme)),
              subtitle: Text(
                l10n.themeSubtitle(
                  t.count,
                  t.latest == null
                      ? '–'
                      : formatEpisodeDate(
                          t.latest!,
                          now: now,
                          locale: l10n.localeName,
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
