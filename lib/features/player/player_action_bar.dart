import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../audio/sleep_timer.dart';
import '../../core/formatting.dart';
import '../../data/db/app_database.dart' show Bookmark;
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'boost_sheet.dart';
import 'chapters_and_bookmarks.dart';
import 'speed_sheet.dart';

/// How much of the four buttons is shown (user wish 2026-10-16): as wide as
/// they fit – labelled when there is room (landscape), otherwise only icons
/// (boost with its dB value, tempo with its factor), on very narrow screens
/// or with huge fonts icons only.
enum PlayerActionMode { full, compact, icons }

/// One button of the bar with what it shows in each mode.
class _Action {
  const _Action({
    required this.key,
    required this.icon,
    required this.full,
    required this.tooltip,
    required this.onPressed,
    this.compact,
    this.onLongPress,
  });

  final Key key;
  final IconData icon;

  /// Label in [PlayerActionMode.full].
  final String full;

  /// Short text next to the icon in [PlayerActionMode.compact]; null = icon
  /// only.
  final String? compact;

  /// Name for screen readers and hover when the button has no label.
  final String tooltip;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  String? labelIn(PlayerActionMode mode) => switch (mode) {
    PlayerActionMode.full => full,
    PlayerActionMode.compact => compact,
    PlayerActionMode.icons => null,
  };
}

/// The four buttons under the play row, pinned to the bottom of the player:
/// bookmark (long press: list), sleep timer, boost and tempo, in one row.
class PlayerActionBar extends ConsumerWidget {
  const PlayerActionBar({
    required this.episodeId,
    required this.podcastId,
    required this.bookmarks,
    super.key,
  });

  final int episodeId;
  final int? podcastId;

  /// False for provisional podcasts: nothing is stored for them (user wish
  /// 2026-10-05), so no bookmarks and no boost either.
  final bool bookmarks;

  static const bookmarkKey = ValueKey('player-action-bookmark');
  static const sleepKey = ValueKey('player-action-sleep');
  static const boostKey = ValueKey('player-action-boost');
  static const speedKey = ValueKey('player-action-speed');

  /// Width of an icon-only button.
  static const iconButtonWidth = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final saved = bookmarks
        ? ref.watch(episodeBookmarksProvider(episodeId)).value ??
              const <Bookmark>[]
        : const <Bookmark>[];

    ref.watch(sleepTimerProvider);
    final handler = ref.read(audioHandlerProvider);
    final sleep = handler.sleepTimerState;
    // The position ticks while playing – enough to refresh the countdown.
    if (sleep.isActive) ref.watch(positionProvider);
    final sleepLabel = switch (sleep.timer) {
      SleepTimerOff() => l10n.sleepTimer,
      SleepTimerAfter() => l10n.sleepTimerLeft(formatClock(sleep.remaining!)),
      SleepTimerAtEpisodeEnd() => l10n.sleepTimerEpisodeEndShort,
    };

    final speed = ref.watch(speedSettingProvider(podcastId)).speed;
    final speedFull = l10n.speedButton(
      speed == 1 ? l10n.boostOff : formatSpeed(l10n, speed),
    );

    final boostId = podcastId;
    final boost = boostId != null && bookmarks
        ? ref.watch(boostSettingProvider(boostId))
        : null;
    final boostValue = boost == null
        ? ''
        : boost.db <= 0
        ? l10n.boostOff
        : l10n.boostValue(boost.db.round());

    final actions = [
      if (bookmarks)
        _Action(
          key: bookmarkKey,
          icon: Icons.bookmark_add_outlined,
          full: l10n.bookmarkAdd,
          tooltip: saved.isEmpty
              ? l10n.bookmarkAdd
              : '${l10n.bookmarkAdd}\n${l10n.bookmarkListHint(saved.length)}',
          onPressed: () => addBookmarkHere(context, ref, episodeId),
          // The list of this episode's bookmarks (replaces the former
          // fifth button "Lesezeichen (n)").
          onLongPress: saved.isEmpty
              ? null
              : () => showEpisodeBookmarksSheet(context, episodeId),
        ),
      _Action(
        key: sleepKey,
        icon: sleep.isActive ? Icons.timer : Icons.timer_outlined,
        full: sleepLabel,
        tooltip: sleep.isActive
            ? '${l10n.sleepTimer}: $sleepLabel'
            : l10n.sleepTimer,
        onPressed: () => SleepTimerButton.choose(context, ref),
      ),
      if (boost != null && boostId != null)
        _Action(
          key: boostKey,
          icon: boost.db > 0 ? Icons.volume_up : Icons.volume_down,
          full: l10n.boostButton(boostValue),
          compact: boostValue,
          tooltip: l10n.boostButton(boostValue),
          onPressed: () => showBoostSheet(context, boostId),
        ),
      _Action(
        key: speedKey,
        icon: Icons.speed,
        full: speedFull,
        compact: formatSpeed(l10n, speed),
        tooltip: speedFull,
        onPressed: () => showSpeedSheet(context, podcastId: podcastId),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = modeFor(context, [
          for (final a in actions) (a.full, a.compact),
        ], constraints.maxWidth);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [for (final a in actions) _ActionButton(a, mode)],
        );
      },
    );
  }

  /// The most complete [PlayerActionMode] whose buttons fit into [width],
  /// measured with the real text and font scale.
  static PlayerActionMode modeFor(
    BuildContext context,
    List<(String full, String? compact)> labels,
    double width,
  ) {
    final style = Theme.of(context).textTheme.labelLarge;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double textWidth(String text) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final w = painter.width;
      painter.dispose();
      return w;
    }

    // Icon 18 + gap 8 + text + padding 2 × 16 (TextButton.icon), plus a
    // little room between the buttons.
    const iconAndPadding = 18 + 8 + 32;
    const between = 4;
    double total(String? Function((String, String?)) label) {
      var sum = 0.0;
      for (final l in labels) {
        final text = label(l);
        sum +=
            (text == null
                ? iconButtonWidth
                : textWidth(text) + iconAndPadding) +
            between;
      }
      return sum;
    }

    if (total((l) => l.$1) <= width) return PlayerActionMode.full;
    if (total((l) => l.$2) <= width) return PlayerActionMode.compact;
    return PlayerActionMode.icons;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.action, this.mode);

  final _Action action;
  final PlayerActionMode mode;

  @override
  Widget build(BuildContext context) {
    final label = action.labelIn(mode);
    final Widget button = label == null
        ? TextButton(
            key: action.key,
            onPressed: action.onPressed,
            onLongPress: action.onLongPress,
            style: TextButton.styleFrom(
              minimumSize: const Size.square(PlayerActionBar.iconButtonWidth),
              padding: EdgeInsets.zero,
            ),
            child: Icon(action.icon),
          )
        : TextButton.icon(
            key: action.key,
            onPressed: action.onPressed,
            onLongPress: action.onLongPress,
            icon: Icon(action.icon),
            label: Text(label, maxLines: 1),
          );
    // Without a label the button needs a name for screen readers; manual
    // trigger so the tooltip does not swallow the long press.
    return mode == PlayerActionMode.full
        ? button
        : Tooltip(
            message: action.tooltip,
            triggerMode: TooltipTriggerMode.manual,
            child: button,
          );
  }
}
