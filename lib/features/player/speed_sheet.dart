import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../audio/audio_providers.dart';
import '../../audio/podcast_audio_handler.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// "1,2x" / "1.2x" in the app language.
String formatSpeed(AppLocalizations l10n, double speed) =>
    '${NumberFormat('0.0', l10n.localeName).format(speed)}x';

/// Label of a speed choice: "Aus (1,0x)" for normal speed.
String speedLabel(AppLocalizations l10n, double speed) =>
    speed == 1 ? l10n.speedOff(formatSpeed(l10n, 1)) : formatSpeed(l10n, speed);

/// [podcastId]: the podcast playing now – its own speed can be chosen
/// ("Nur für diesen Podcast", user wish 2026-10-20).
Future<void> showSpeedSheet(BuildContext context, {int? podcastId}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SpeedSheet(podcastId: podcastId),
    );

class _SpeedSheet extends ConsumerWidget {
  const _SpeedSheet({this.podcastId});

  final int? podcastId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final setting = ref.watch(speedSettingProvider(podcastId));
    final speed = setting.speed;
    // Nothing is stored for provisional podcasts: no own speed there.
    final provisional = switch (podcastId) {
      final id? => ref.watch(podcastProvider(id)).value?.provisional ?? false,
      null => false,
    };
    // Snap to an offered value (robust against odd stored values).
    final selected = PodcastAudioHandler.speeds.reduce(
      (a, b) => (a - speed).abs() <= (b - speed).abs() ? a : b,
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.speedTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SegmentedButton<double>(
              showSelectedIcon: false,
              segments: [
                for (final s in PodcastAudioHandler.speeds)
                  ButtonSegment(value: s, label: Text(speedLabel(l10n, s))),
              ],
              selected: {selected},
              onSelectionChanged: (values) => handler.setSpeedChoice(
                values.single,
                forPodcastOnly: setting.perPodcast,
              ),
            ),
            if (podcastId != null && !provisional) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.speedPerPodcast),
                subtitle: Text(l10n.speedPerPodcastHint),
                value: setting.perPodcast,
                onChanged: (perPodcast) => perPodcast
                    ? handler.setSpeedChoice(selected, forPodcastOnly: true)
                    : handler.clearPodcastSpeed(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
