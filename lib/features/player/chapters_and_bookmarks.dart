import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../audio/sleep_timer.dart';
import '../../core/formatting.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../core/widgets/text_input_dialog.dart';
import '../../data/chapters/chapter_service.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Current chapter under the seek bar; tap opens the chapter list.
class CurrentChapterLine extends ConsumerWidget {
  const CurrentChapterLine({required this.episodeId, super.key});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider(episodeId)).value ?? const [];
    if (chapters.isEmpty) return const SizedBox(height: 8);
    final position =
        ref.watch(positionProvider).value ??
        ref.read(audioHandlerProvider).position;
    final current = currentChapter(chapters, position);
    if (current == null) return const SizedBox(height: 8);
    final index = chapters.indexOf(current) + 1;
    return TextButton.icon(
      onPressed: () => showChaptersSheet(context, episodeId),
      icon: const Icon(Icons.format_list_numbered, size: 18),
      label: Text(
        AppLocalizations.of(context)
            .chapterCurrent(index, chapters.length, current.title),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Buttons under the player controls: add bookmark, sleep timer, bookmarks.
/// The chapter list opens from [CurrentChapterLine].
class ChapterBookmarkButtons extends ConsumerWidget {
  const ChapterBookmarkButtons({
    required this.episodeId,
    this.bookmarks = true,
    super.key,
  });

  final int episodeId;

  /// False for provisional podcasts: nothing is stored for them (user wish
  /// 2026-10-05), so no bookmarks either.
  final bool bookmarks;

  Future<void> _addBookmark(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // Take the position first – playback continues while the dialog is open.
    final position = ref.read(audioHandlerProvider).position;
    final note = await showTextInputDialog(
      context,
      title: l10n.bookmarkAdd,
      confirmLabel: l10n.save,
      label: l10n.bookmarkNote,
      allowEmpty: true,
    );
    if (note == null) return;
    await ref
        .read(bookmarkRepositoryProvider)
        .add(episodeId, position, note: note);
    showInfoSnackBar(messenger, l10n.bookmarkAdded(formatClock(position)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final saved =
        ref.watch(episodeBookmarksProvider(episodeId)).value ?? const [];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        if (bookmarks)
          TextButton.icon(
            onPressed: () => _addBookmark(context, ref),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(l10n.bookmarkAdd),
          ),
        const SleepTimerButton(),
        if (bookmarks && saved.isNotEmpty)
          TextButton.icon(
            onPressed: () => showEpisodeBookmarksSheet(context, episodeId),
            icon: const Icon(Icons.bookmarks_outlined),
            label: Text(l10n.bookmarksCount(saved.length)),
          ),
      ],
    );
  }
}

/// Stopwatch button: shows the sleep timer, tap to choose (docs/playback.md).
class SleepTimerButton extends ConsumerWidget {
  const SleepTimerButton({super.key});

  static const minuteChoices = [5, 15, 30, 60];

  /// Limits for "Eigene Zeit" (user request: 1 to 3600 minutes).
  static const customMin = 1;
  static const customMax = 3600;

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final handler = ref.read(audioHandlerProvider);
    final timer = handler.sleepTimerState.timer;
    final customMinutes = switch (timer) {
      SleepTimerAfter(:final duration)
          when !minuteChoices.contains(duration.inMinutes) =>
        duration.inMinutes,
      _ => null,
    };
    final current = switch (timer) {
      SleepTimerOff() => 'off',
      SleepTimerAfter() when customMinutes != null => 'custom',
      SleepTimerAfter(:final duration) => '${duration.inMinutes}',
      SleepTimerAtEpisodeEnd() => 'end',
    };
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.sleepTimer),
        children: [
          // Tapping the selected entry counts too (toggleable reports it as
          // null): e.g. to change "Eigene Zeit" or restart the countdown.
          RadioGroup<String>(
            groupValue: current,
            onChanged: (v) => Navigator.of(context).pop(v ?? current),
            child: Column(
              children: [
                RadioListTile(
                  value: 'off',
                  toggleable: true,
                  title: Text(l10n.sleepTimerOff),
                ),
                for (final m in minuteChoices)
                  RadioListTile(
                    value: '$m',
                    toggleable: true,
                    title: Text(l10n.sleepTimerMinutes(m)),
                  ),
                RadioListTile(
                  value: 'custom',
                  toggleable: true,
                  title: Text(
                    customMinutes == null
                        ? l10n.sleepTimerCustom
                        : l10n.sleepTimerCustomSet(customMinutes),
                  ),
                ),
                RadioListTile(
                  value: 'end',
                  toggleable: true,
                  title: Text(l10n.sleepTimerEpisodeEnd),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null) return;
    if (chosen == 'custom') {
      if (!context.mounted) return;
      final minutes = await showDialog<int>(
        context: context,
        builder: (_) => _CustomMinutesDialog(initial: customMinutes),
      );
      if (minutes == null) return;
      handler.setSleepTimer(SleepTimerAfter(Duration(minutes: minutes)));
      return;
    }
    handler.setSleepTimer(switch (chosen) {
      'off' => const SleepTimerOff(),
      'end' => const SleepTimerAtEpisodeEnd(),
      _ => SleepTimerAfter(Duration(minutes: int.parse(chosen))),
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.watch(sleepTimerProvider);
    // The position ticks while playing – enough to refresh the countdown.
    ref.watch(positionProvider);
    final state = ref.read(audioHandlerProvider).sleepTimerState;
    final label = switch (state.timer) {
      SleepTimerOff() => l10n.sleepTimer,
      SleepTimerAfter() => l10n.sleepTimerLeft(formatClock(state.remaining!)),
      SleepTimerAtEpisodeEnd() => l10n.sleepTimerEpisodeEndShort,
    };
    return TextButton.icon(
      onPressed: () => _choose(context, ref),
      icon: Icon(state.isActive ? Icons.timer : Icons.timer_outlined),
      label: Text(label),
    );
  }
}

/// Number field for "Eigene Zeit": whole minutes from
/// [SleepTimerButton.customMin] to [SleepTimerButton.customMax].
class _CustomMinutesDialog extends StatefulWidget {
  const _CustomMinutesDialog({this.initial});

  final int? initial;

  @override
  State<_CustomMinutesDialog> createState() => _CustomMinutesDialogState();
}

class _CustomMinutesDialogState extends State<_CustomMinutesDialog> {
  late final _controller = TextEditingController(
    text: widget.initial?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The entered minutes if valid, otherwise null.
  int? get _minutes {
    final value = int.tryParse(_controller.text);
    if (value == null ||
        value < SleepTimerButton.customMin ||
        value > SleepTimerButton.customMax) {
      return null;
    }
    return value;
  }

  void _submit() {
    final minutes = _minutes;
    if (minutes != null) Navigator.of(context).pop(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final valid = _minutes != null;
    return AlertDialog(
      title: Text(l10n.sleepTimerCustom),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        decoration: InputDecoration(
          labelText: l10n.sleepTimerCustomLabel,
          helperText: l10n.sleepTimerCustomRange(
            SleepTimerButton.customMin,
            SleepTimerButton.customMax,
          ),
          errorText: _controller.text.isEmpty || valid
              ? null
              : l10n.sleepTimerCustomRange(
                  SleepTimerButton.customMin,
                  SleepTimerButton.customMax,
                ),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: valid ? _submit : null,
          child: Text(l10n.sleepTimerStart),
        ),
      ],
    );
  }
}

/// Closes a sheet about [episodeId] as soon as another episode is in the
/// player (end of the episode, ⏭ …; user wish 2026-10-06) – it would show
/// the old episode's chapters or bookmarks otherwise.
void _closeOnEpisodeChange(BuildContext context, WidgetRef ref, int episodeId) {
  ref.listen(mediaItemProvider.select((s) => s.value?.mediaItem?.id), (
    _,
    current,
  ) {
    if (current == null || current == '$episodeId') return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    final navigator = Navigator.of(context);
    // Something opened above it (e.g. a dialog): remove just the sheet.
    route.isCurrent ? navigator.pop() : navigator.removeRoute(route);
  });
}

Future<void> showChaptersSheet(BuildContext context, int episodeId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _ChaptersSheet(episodeId: episodeId),
    );

class _ChaptersSheet extends ConsumerWidget {
  const _ChaptersSheet({required this.episodeId});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _closeOnEpisodeChange(context, ref, episodeId);
    final l10n = AppLocalizations.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final chapters = ref.watch(chaptersProvider(episodeId)).value ?? const [];
    final position = ref.watch(positionProvider).value ?? handler.position;
    final current = currentChapter(chapters, position);
    final skipped =
        ref.watch(skippedChaptersProvider(episodeId)).value ?? const {};
    final colors = Theme.of(context).colorScheme;
    final episodeLength = ref.watch(
      mediaItemProvider.select((s) => s.value?.mediaItem?.duration),
    );

    /// Share of chapter [index] already heard (0…1), from the same position
    /// stream as the player's slider; null if its end is unknown.
    double? progressOf(int index) {
      final start = chapters[index].startMs;
      final end = index + 1 < chapters.length
          ? chapters[index + 1].startMs
          : episodeLength?.inMilliseconds;
      if (end == null || end <= start) return null;
      return ((position.inMilliseconds - start) / (end - start)).clamp(
        0.0,
        1.0,
      );
    }

    Future<void> setSkipped(int index, {required bool skip}) =>
        handler.setChapterSkipped(
          episodeId,
          chapters[index].startMs,
          endMs: index + 1 < chapters.length
              ? chapters[index + 1].startMs
              : null,
          skipped: skip,
        );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chapters, style: Theme.of(context).textTheme.titleMedium),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final c = chapters[index];
                  final isSkipped = skipped.contains(c.startMs);
                  final start = Text(
                    formatClock(Duration(milliseconds: c.startMs)),
                  );
                  // The chapter playing now: live percentage and a thick bar
                  // across the whole text area, up to the Skip chip (user
                  // wish 2026-10-06).
                  final progress = c == current ? progressOf(index) : null;
                  return ListTile(
                    selected: c == current,
                    selectedTileColor: colors.secondaryContainer,
                    leading: c.imageUrl == null
                        ? null
                        : CoverImage(url: c.imageUrl, size: 40),
                    title: Text(
                      c.title,
                      style: isSkipped
                          ? TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: colors.onSurfaceVariant,
                            )
                          : null,
                    ),
                    subtitle: progress == null
                        ? start
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  start,
                                  const Spacer(),
                                  Text(
                                    l10n.chapterProgress(
                                      (progress * 100).floor(),
                                    ),
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: colors.primary.withValues(
                                    alpha: 0.18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    trailing: FilterChip(
                      label: Text(l10n.chapterSkip),
                      tooltip: l10n.chapterSkipHint,
                      selected: isSkipped,
                      onSelected: (skip) =>
                          unawaited(setSkipped(index, skip: skip)),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      // Choosing a chapter means: hear it after all.
                      if (isSkipped) await setSkipped(index, skip: false);
                      await handler.seek(Duration(milliseconds: c.startMs));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showEpisodeBookmarksSheet(BuildContext context, int episodeId) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _EpisodeBookmarksSheet(episodeId: episodeId),
    );

class _EpisodeBookmarksSheet extends ConsumerWidget {
  const _EpisodeBookmarksSheet({required this.episodeId});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _closeOnEpisodeChange(context, ref, episodeId);
    final l10n = AppLocalizations.of(context);
    final bookmarks =
        ref.watch(episodeBookmarksProvider(episodeId)).value ?? const [];
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.bookmarks,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final b in bookmarks)
                    BookmarkTile(
                      bookmark: b,
                      onTap: () {
                        Navigator.of(context).pop();
                        unawaited(
                          ref
                              .read(audioHandlerProvider)
                              .seek(Duration(milliseconds: b.positionMs)),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One bookmark: time, note, delete; long press edits the note.
class BookmarkTile extends ConsumerWidget {
  const BookmarkTile({
    required this.bookmark,
    required this.onTap,
    this.subtitle,
    this.leading,
    super.key,
  });

  final Bookmark bookmark;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? leading;

  Future<void> _editNote(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final note = await showTextInputDialog(
      context,
      title: l10n.bookmarkEditNote,
      confirmLabel: l10n.save,
      label: l10n.bookmarkNote,
      initialValue: bookmark.note ?? '',
      allowEmpty: true,
    );
    if (note != null) {
      await ref.read(bookmarkRepositoryProvider).updateNote(bookmark.id, note);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final time = formatClock(Duration(milliseconds: bookmark.positionMs));
    return ListTile(
      leading: leading ?? const Icon(Icons.bookmark_outline),
      title: Text(bookmark.note ?? time),
      subtitle: Text([if (bookmark.note != null) time, ?subtitle].join(' · ')),
      onTap: onTap,
      onLongPress: () => _editNote(context, ref),
      trailing: IconButton(
        tooltip: l10n.delete,
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          await ref.read(bookmarkRepositoryProvider).delete(bookmark.id);
          showInfoSnackBar(messenger, l10n.bookmarkDeleted);
        },
      ),
    );
  }
}
