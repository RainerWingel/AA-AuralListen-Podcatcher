import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../core/widgets/cover_image.dart';
import '../../data/chapters/chapter_image_store.dart';
import '../../data/chapters/chapter_service.dart';
import '../../data/providers.dart';
import '../../data/storage/cover_cache.dart';

/// After this long in pause the player shows the episode picture again
/// instead of the chapter's (user wish 2026-10-11).
const chapterPicturePauseDelay = Duration(minutes: 2);

/// Reference of the picture of the chapter playing now in [episodeId]; null
/// if there is no chapter or it has no picture. Only changes when the
/// picture does, not with every position tick.
final currentChapterPictureProvider = Provider.autoDispose.family<String?, int>(
  (ref, episodeId) {
    final chapters = ref.watch(chaptersProvider(episodeId)).value;
    if (chapters == null || chapters.isEmpty) return null;
    final position =
        ref.watch(positionProvider).value ??
        ref.read(audioHandlerProvider).position;
    return currentChapter(chapters, position)?.imageUrl;
  },
);

/// A chapter's picture: a web address (JSON chapters) or a file kept from
/// the MP3 ([ChapterImageStore]). [fallback] shows while loading and when the
/// picture is gone. Decoded only at display size (docs/eviction.md).
class ChapterPicture extends ConsumerWidget {
  const ChapterPicture({
    required this.reference,
    required this.size,
    required this.fallback,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String reference;
  final double size;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decodeWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final Widget picture;
    if (ChapterImageStore.isLocal(reference)) {
      final file = ref.watch(chapterImageFileProvider(reference)).value;
      picture = file == null
          ? fallback
          : Image.file(
              file,
              cacheWidth: decodeWidth,
              fit: fit,
              errorBuilder: (context, error, stack) => fallback,
            );
    } else {
      picture = CachedNetworkImage(
        imageUrl: reference,
        cacheManager: CoverCacheManager.instance,
        memCacheWidth: decodeWidth,
        fit: fit,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      );
    }
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size < 80 ? 6 : 10),
        child: picture,
      ),
    );
  }
}

/// Whether the player shows chapter pictures right now: from the moment play
/// was pressed until [chapterPicturePauseDelay] after a pause. Lives while
/// the player is open (the backdrop and the cover share it).
final chapterPicturesOnProvider =
    NotifierProvider.autoDispose<_ChapterPicturesOn, bool>(
      _ChapterPicturesOn.new,
    );

class _ChapterPicturesOn extends Notifier<bool> {
  Timer? _pauseTimer;

  @override
  bool build() {
    ref.onDispose(() => _pauseTimer?.cancel());
    ref.listen(
      playbackStateProvider.select((s) => s.value?.playing ?? false),
      (_, playing) => _onPlaying(playing),
    );
    return ref.read(playbackStateProvider).value?.playing ?? false;
  }

  void _onPlaying(bool playing) {
    _pauseTimer?.cancel();
    _pauseTimer = null;
    if (playing) {
      state = true;
      return;
    }
    _pauseTimer = Timer(chapterPicturePauseDelay, () {
      _pauseTimer = null;
      state = false;
    });
  }
}

/// The chapter picture to show now in [episodeId] (see
/// [chapterPicturesOnProvider], [currentChapterPictureProvider]); null = the
/// episode cover.
final playerPictureProvider = Provider.autoDispose.family<String?, int>(
  (ref, episodeId) => ref.watch(chapterPicturesOnProvider)
      ? ref.watch(currentChapterPictureProvider(episodeId))
      : null,
);

/// The big picture in the full-screen player: the episode's cover – or, once
/// play was pressed and the position is in a chapter with a picture, that
/// picture. Two minutes after pause the episode cover returns.
class PlayerCover extends ConsumerWidget {
  const PlayerCover({
    required this.episodeId,
    required this.coverUrl,
    required this.size,
    super.key,
  });

  final int? episodeId;
  final String? coverUrl;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = episodeId;
    final picture = id == null ? null : ref.watch(playerPictureProvider(id));
    final cover = CoverImage(url: coverUrl, size: size);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: SizedBox.square(
        key: ValueKey(picture ?? 'episode'),
        dimension: size,
        child: picture == null
            ? cover
            : ChapterPicture(
                reference: picture,
                size: size,
                fallback: cover,
                // The whole picture, also a portrait one (user wish
                // 2026-10-11).
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
