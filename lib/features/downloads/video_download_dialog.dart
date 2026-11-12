import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../data/db/app_database.dart';
import '../../data/video_episodes.dart';
import '../../l10n/app_localizations.dart';

/// Before a video episode is downloaded by hand, asks how (docs/eviction.md):
/// "Nur WLAN" (suggested) → true, "Sofort laden" → false, canceled → null.
/// Other episodes: false without asking (downloaded right away as before).
Future<bool?> askVideoDownloadWifiOnly(
  BuildContext context,
  Episode episode,
) async {
  if (!episode.isVideo) return false;
  final l10n = AppLocalizations.of(context);
  final size = episode.audioSizeBytes;
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.videoDownloadTitle),
      content: Text(
        size == null
            ? l10n.videoDownloadLarge
            : l10n.videoDownloadSize(formatBytes(size, l10n.localeName)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.videoDownloadNow),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.autoDownloadWifi),
        ),
      ],
    ),
  );
}
