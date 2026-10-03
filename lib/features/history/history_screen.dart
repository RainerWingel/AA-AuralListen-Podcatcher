import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../audio/audio_providers.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// "Abspielverlauf": episodes played to the end, newest first (max. 100).
/// Tap plays the episode again while it is still subscribed.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    HistoryEntry entry,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final gone = AppLocalizations.of(context).historyEpisodeGone;
    final id = await ref.read(historyRepositoryProvider).episodeIdOf(entry);
    if (id == null) {
      showInfoSnackBar(messenger, gone);
      return;
    }
    await ref.read(audioHandlerProvider).playEpisode(id);
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.historyClear),
        content: Text(l10n.historyClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.historyClearAction),
          ),
        ],
      ),
    );
    if (confirmed == true) await ref.read(historyRepositoryProvider).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(playHistoryProvider);
    final hasEntries = entries.value?.isNotEmpty ?? false;
    final when = DateFormat.yMMMd(l10n.localeName).add_Hm();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          if (hasEntries)
            IconButton(
              tooltip: l10n.historyClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _clear(context, ref),
            ),
        ],
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.loadError)),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.history,
                title: l10n.historyEmpty,
                hint: l10n.historyEmptyHint,
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final e = items[index];
                  return ListTile(
                    leading: CoverImage(url: e.imageUrl, size: 48),
                    title: Text(
                      e.episodeTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${e.podcastTitle}\n'
                      '${when.format(e.playedAt.toLocal())}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _play(context, ref, e),
                  );
                },
              ),
      ),
    );
  }
}
