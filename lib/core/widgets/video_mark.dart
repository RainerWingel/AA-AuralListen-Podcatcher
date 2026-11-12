import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Small camera in front of the date: a video episode (docs/ui-ux.md).
class VideoMark extends StatelessWidget {
  const VideoMark({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Tooltip(
      message: AppLocalizations.of(context).episodeVideo,
      child: Icon(
        Icons.videocam_outlined,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
