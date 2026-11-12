import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio/audio_providers.dart';
import '../../audio/video_output.dart';
import '../../core/widgets/cover_image.dart';
import '../../l10n/app_localizations.dart';
import 'chapter_cover.dart';
import 'player_controls.dart';
import 'player_screen.dart' show PlayerSeekBar;

/// The texture of [VideoOutput] while this widget lives; [fallback] until
/// the first picture is on it (and while the app is in the background).
class VideoPicture extends ConsumerStatefulWidget {
  const VideoPicture({required this.fallback, super.key});

  final Widget fallback;

  @override
  ConsumerState<VideoPicture> createState() => _VideoPictureState();
}

class _VideoPictureState extends ConsumerState<VideoPicture> {
  late final VideoOutput _output = ref.read(videoOutputProvider);

  @override
  void initState() {
    super.initState();
    _output.acquire();
  }

  @override
  void dispose() {
    _output.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int?>(
    valueListenable: _output.picture,
    builder: (context, texture, _) => texture == null
        ? widget.fallback
        : Texture(textureId: texture, filterQuality: FilterQuality.medium),
  );
}

/// The big picture in the player: the video of a video episode (a tap opens
/// it full screen), otherwise [PlayerCover].
class PlayerPicture extends ConsumerWidget {
  const PlayerPicture({
    required this.episodeId,
    required this.coverUrl,
    required this.coverSize,
    required this.maxWidth,
    super.key,
  });

  final int? episodeId;
  final String? coverUrl;
  final double coverSize;

  /// Width available to a video (wider than the square cover).
  final double maxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ValueListenableBuilder<VideoFormat?>(
        valueListenable: ref.watch(videoOutputProvider).format,
        builder: (context, format, _) {
          if (format == null) {
            return PlayerCover(
              episodeId: episodeId,
              coverUrl: coverUrl,
              size: coverSize,
            );
          }
          // As wide as possible, but never taller than the cover would be.
          var width = maxWidth;
          var height = width / format.aspectRatio;
          if (height > coverSize) {
            height = coverSize;
            width = height * format.aspectRatio;
          }
          final l10n = AppLocalizations.of(context);
          return Semantics(
            button: true,
            label: l10n.videoFullscreen,
            child: GestureDetector(
              onTap: () => openVideoFullscreen(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: Colors.black,
                        child: VideoPicture(
                          fallback: Center(
                            child: CoverImage(url: coverUrl, size: height),
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 4,
                        bottom: 4,
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

/// Shows the video full screen (landscape for a wide picture).
Future<void> openVideoFullscreen(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => const VideoFullscreenScreen(),
      ),
    );

/// After this long without a touch the controls over the playing video hide.
const videoControlsHideDelay = Duration(seconds: 3);

/// Leaving full screen: this long upright, then the phone may turn freely
/// again (a phone lying flat would otherwise stay sideways).
const videoPortraitHold = Duration(seconds: 2);

/// Black screen with the video; a tap shows the controls. Closes itself when
/// the episode has no picture any more (next episode is audio, player
/// stopped).
class VideoFullscreenScreen extends ConsumerStatefulWidget {
  const VideoFullscreenScreen({super.key});

  @override
  ConsumerState<VideoFullscreenScreen> createState() =>
      _VideoFullscreenScreenState();
}

class _VideoFullscreenScreenState extends ConsumerState<VideoFullscreenScreen> {
  /// Counts full screens opened; a release of the orientation from an
  /// earlier one must not undo the lock of a newer one.
  static int _opened = 0;

  late final VideoOutput _output = ref.read(videoOutputProvider);
  bool _controls = true;
  Timer? _hideTimer;
  bool? _landscape;

  @override
  void initState() {
    super.initState();
    _opened++;
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    _output.format.addListener(_onFormat);
    _onFormat();
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _output.format.removeListener(_onFormat);
    // Upright like before, then back to what the app allows everywhere
    // else (one-shot future, nothing to cancel).
    unawaited(
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
      ]),
    );
    final opened = _opened;
    unawaited(
      Future<void>.delayed(videoPortraitHold, () {
        if (_opened == opened) {
          return SystemChrome.setPreferredOrientations(const []);
        }
      }),
    );
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  void _onFormat() {
    final format = _output.format.value;
    if (format == null) {
      // Deferred: may be called during a build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _output.format.value == null) {
          Navigator.of(context).maybePop();
        }
      });
      return;
    }
    final landscape = format.aspectRatio >= 1;
    if (landscape == _landscape) return;
    _landscape = landscape;
    unawaited(
      SystemChrome.setPreferredOrientations(
        landscape
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : const [DeviceOrientation.portraitUp],
      ),
    );
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(videoControlsHideDelay, () {
      final playing = ref.read(playbackStateProvider).value?.playing ?? false;
      if (mounted && playing) setState(() => _controls = false);
    });
  }

  void _toggleControls() {
    setState(() => _controls = !_controls);
    if (_controls) _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = ref.watch(mediaItemProvider).value?.mediaItem;
    final colors = ColorScheme.fromSeed(
      seedColor: Theme.of(context).colorScheme.primary,
      brightness: Brightness.dark,
    );
    return Theme(
      data: ThemeData(colorScheme: colors),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ValueListenableBuilder<VideoFormat?>(
                valueListenable: _output.format,
                builder: (context, format, _) => Center(
                  child: AspectRatio(
                    aspectRatio: format?.aspectRatio ?? 16 / 9,
                    child: VideoPicture(
                      fallback: LayoutBuilder(
                        builder: (context, constraints) => Center(
                          child: CoverImage(
                            url: item?.artUri?.toString(),
                            size: min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_controls)
                // Taps on the controls keep them visible a while longer.
                Listener(
                  onPointerDown: (_) => _scheduleHide(),
                  child: ColoredBox(
                    color: Colors.black45,
                    child: SafeArea(
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.topStart,
                            child: IconButton(
                              tooltip: l10n.videoExitFullscreen,
                              color: Colors.white,
                              icon: const Icon(Icons.fullscreen_exit),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SkipButton.back(),
                              PlayPauseButton(size: 48, filled: true),
                              SkipButton.forward(),
                            ],
                          ),
                          const Spacer(),
                          if (item != null)
                            PlayerSeekBar(
                              total: item.duration,
                              podcastId: item.extras?['podcastId'] as int?,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
