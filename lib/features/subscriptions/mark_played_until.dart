import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Podcast menu → "Als gehört markieren bis …": pick a date, confirm with the
/// number of affected episodes, mark them as played.
Future<void> markPlayedUntilFlow(
  BuildContext context,
  WidgetRef ref,
  Podcast podcast,
  List<Episode> episodes,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final playback = ref.read(playbackRepositoryProvider);
  final now = ref.read(clockProvider)();
  final today = DateTime(now.year, now.month, now.day);

  final dates = episodes.map((e) => e.pubDate).nonNulls.map((d) => d.toLocal());
  final oldest = dates.isEmpty
      ? today
      : dates.reduce((a, b) => a.isBefore(b) ? a : b);
  final firstDate = DateTime(oldest.year, oldest.month, oldest.day);

  final picked = await showDatePicker(
    context: context,
    helpText: l10n.markPlayedUntilPick,
    initialDate: today,
    firstDate: firstDate.isAfter(today) ? today : firstDate,
    lastDate: today,
  );
  if (picked == null || !context.mounted) return;

  // Inclusive: everything published on the picked day counts too.
  final until = DateTime(
    picked.year,
    picked.month,
    picked.day + 1,
  ).subtract(const Duration(milliseconds: 1));
  final dateText = DateFormat.yMMMMd('de').format(picked);
  final count = await playback.countUnplayedUntil(podcast.id, until);
  if (!context.mounted) return;
  if (count == 0) {
    showInfoSnackBar(messenger, l10n.markPlayedUntilNone(dateText));
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.markPlayedUntil),
      content: Text(
        '${l10n.markPlayedUntilConfirm(count, dateText)}\n\n'
        '${l10n.markPlayedUntilHint}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.markAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  final marked = await playback.markPlayedUntil(podcast.id, until);
  showInfoSnackBar(messenger, l10n.markPlayedUntilDone(marked));
}
