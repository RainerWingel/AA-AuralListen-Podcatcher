import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../audio/audio_providers.dart';
import '../../core/widgets/cover_image.dart';
import '../../l10n/app_localizations.dart';
import 'player_controls.dart';

/// Bar above the bottom navigation: current episode, play/pause, progress.
/// Hidden while nothing was played yet.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(mediaItemProvider).value?.mediaItem;
    if (item == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: InkWell(
        onTap: () => context.push(Routes.player),
        child: Semantics(
          label: AppLocalizations.of(context).playerOpen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniProgress(total: item.duration),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                child: Row(
                  children: [
                    CoverImage(url: item.artUri?.toString(), size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            item.album ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const PlayPauseButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgress extends ConsumerWidget {
  const _MiniProgress({required this.total});

  final Duration? total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionProvider).value;
    final total = this.total;
    final value = position == null || total == null || total <= Duration.zero
        ? 0.0
        : (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    return LinearProgressIndicator(value: value, minHeight: 2);
  }
}
