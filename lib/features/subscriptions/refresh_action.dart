import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/info_snack_bar.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Pull-to-refresh handler shared by several screens.
/// Refreshes all feeds and reports moved and failed feeds in a snackbar.
Future<void> refreshAllFeeds(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final summary = await ref.read(podcastRepositoryProvider).refreshAll();
  // New episodes may need auto-downloading; played ones may be due for deletion.
  unawaited(ref.read(downloadServiceProvider).runMaintenance());
  final messages = [
    if (summary.moved > 0) l10n.feedsMoved(summary.moved),
    if (summary.failed > 0) l10n.refreshFailed(summary.failed),
  ];
  if (messages.isNotEmpty) showInfoSnackBar(messenger, messages.join('\n'));
}
