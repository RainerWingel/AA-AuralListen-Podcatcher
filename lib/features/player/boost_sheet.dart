import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../l10n/app_localizations.dart';

/// Selectable boost levels in dB (0 = off).
const boostLevels = <double>[0, 3, 6, 9, 12];

Future<void> showBoostSheet(BuildContext context, int podcastId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _BoostSheet(podcastId: podcastId),
    );

class _BoostSheet extends ConsumerWidget {
  const _BoostSheet({required this.podcastId});

  final int podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final boost = ref.watch(boostSettingProvider(podcastId));
    // Snap to the nearest offered level (values could come from older versions).
    final selected = boostLevels.reduce(
      (a, b) => (a - boost.db).abs() <= (b - boost.db).abs() ? a : b,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.boostTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<double>(
              showSelectedIcon: false,
              segments: [
                for (final level in boostLevels)
                  ButtonSegment(
                    value: level,
                    label: Text(
                      level == 0
                          ? l10n.boostOff
                          : l10n.boostValue(level.round()),
                    ),
                  ),
              ],
              selected: {selected},
              onSelectionChanged: (values) => handler.setBoost(
                values.single,
                forPodcastOnly: boost.perPodcast,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.boostPerPodcast),
              subtitle: Text(l10n.boostPerPodcastHint),
              value: boost.perPodcast,
              onChanged: (perPodcast) => perPodcast
                  ? handler.setBoost(selected, forPodcastOnly: true)
                  : handler.clearPodcastBoost(),
            ),
          ],
        ),
      ),
    );
  }
}
