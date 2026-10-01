import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Show notes of an episode as plain text in a bottom sheet (long press menu).
Future<void> showEpisodeDescriptionSheet(
  BuildContext context, {
  required String title,
  required String description,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => ConstrainedBox(
    // Long show notes scroll inside the sheet instead of covering the screen.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
    ),
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        SelectableText(description),
      ],
    ),
  ),
);

/// Collapsible "Description" section at the bottom of the full-screen player.
/// Hidden when the episode has no show notes.
class EpisodeDescriptionSection extends ConsumerWidget {
  const EpisodeDescriptionSection({required this.episodeId, super.key});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final description = ref.watch(episodeDescriptionProvider(episodeId)).value;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return ExpansionTile(
      // A new episode starts collapsed again.
      key: ValueKey(episodeId),
      title: Text(AppLocalizations.of(context).episodeDescription),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      expandedAlignment: Alignment.topLeft,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [SelectableText(description)],
    );
  }
}
