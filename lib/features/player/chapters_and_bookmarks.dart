import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
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

/// Buttons under the player controls: chapters, add bookmark, bookmarks.
class ChapterBookmarkButtons extends ConsumerWidget {
  const ChapterBookmarkButtons({required this.episodeId, super.key});

  final int episodeId;

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
    final chapters = ref.watch(chaptersProvider(episodeId)).value ?? const [];
    final bookmarks =
        ref.watch(episodeBookmarksProvider(episodeId)).value ?? const [];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        if (chapters.isNotEmpty)
          TextButton.icon(
            onPressed: () => showChaptersSheet(context, episodeId),
            icon: const Icon(Icons.format_list_numbered),
            label: Text('${l10n.chapters} (${chapters.length})'),
          ),
        TextButton.icon(
          onPressed: () => _addBookmark(context, ref),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(l10n.bookmarkAdd),
        ),
        if (bookmarks.isNotEmpty)
          TextButton.icon(
            onPressed: () => showEpisodeBookmarksSheet(context, episodeId),
            icon: const Icon(Icons.bookmarks_outlined),
            label: Text(l10n.bookmarksCount(bookmarks.length)),
          ),
      ],
    );
  }
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
    final l10n = AppLocalizations.of(context);
    final handler = ref.watch(audioHandlerProvider);
    final chapters = ref.watch(chaptersProvider(episodeId)).value ?? const [];
    final position = ref.watch(positionProvider).value ?? handler.position;
    final current = currentChapter(chapters, position);
    final colors = Theme.of(context).colorScheme;

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
                  return ListTile(
                    selected: c == current,
                    selectedTileColor: colors.secondaryContainer,
                    leading: c.imageUrl == null
                        ? null
                        : CoverImage(url: c.imageUrl, size: 40),
                    title: Text(c.title),
                    trailing: Text(
                      formatClock(Duration(milliseconds: c.startMs)),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      unawaited(
                        handler.seek(Duration(milliseconds: c.startMs)),
                      );
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
