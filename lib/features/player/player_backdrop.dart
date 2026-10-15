import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/image_luminance.dart';
import '../../core/link_color.dart';
import '../../data/chapters/chapter_image_store.dart';
import '../../data/providers.dart';
import '../../data/storage/cover_cache.dart';
import 'chapter_cover.dart';

/// Above this average luminance of the picture the texts on it are dark
/// (black text and white text have the same contrast at about 0.18).
const backdropLightThreshold = 0.2;

/// How strongly the blurred picture is pushed toward the text's opposite
/// (user wish 2026-10-18): a dark picture gets darker, a light one lighter,
/// so medium colors do not interfere with the text.
const backdropDarkVeil = 0.5;
const backdropLightVeil = 0.46;

/// The foreground color for a backdrop of the given average [luminance]:
/// dark on a light picture, light on a dark one.
Color backdropForeground(double luminance) => luminance > backdropLightThreshold
    ? const Color(0xFF14141A)
    : const Color(0xFFF5F5F7);

/// [theme] with its foreground colors changed to [foreground] – for the
/// elements lying on the blurred picture (texts, icons, text buttons,
/// the description's accent color).
ThemeData backdropTheme(ThemeData theme, Color foreground) {
  final scheme = theme.colorScheme.copyWith(
    onSurface: foreground,
    onSurfaceVariant: foreground.withValues(alpha: 0.78),
    primary: foreground,
    onPrimary: theme.colorScheme.surface,
  );
  return theme.copyWith(
    colorScheme: scheme,
    textTheme: theme.textTheme.apply(
      bodyColor: foreground,
      displayColor: foreground,
    ),
    iconTheme: theme.iconTheme.copyWith(color: foreground),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: foreground.withValues(alpha: 0.12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: foreground.withValues(alpha: 0.12),
      ),
    ),
    dividerColor: foreground.withValues(alpha: 0.2),
    // Links stay blue, matching the picture's brightness.
    extensions: [
      ...theme.extensions.values.where((e) => e is! LinkColor),
      LinkColor.forBackground(
        onDarkBackground: foreground.computeLuminance() > 0.5,
      ),
    ],
  );
}

/// Heavily blurred picture behind the scrolling part of the player: the
/// picture shown at the moment (chapter picture or episode cover). The
/// elements in [builder] get a foreground that fits its brightness (user wish
/// 2026-10-17). Without a picture the plain theme stays.
class PlayerBackdrop extends ConsumerStatefulWidget {
  const PlayerBackdrop({
    required this.episodeId,
    required this.coverUrl,
    required this.builder,
    super.key,
  });

  final int? episodeId;
  final String? coverUrl;

  /// Builds the content with the theme adapted to the picture.
  final Widget Function(BuildContext context, ThemeData theme) builder;

  @override
  ConsumerState<PlayerBackdrop> createState() => _PlayerBackdropState();
}

class _PlayerBackdropState extends ConsumerState<PlayerBackdrop> {
  ImageProvider? _provider;

  /// Average luminance of the current picture; kept while the next one is
  /// measured, so the texts do not flash.
  double? _luminance;

  static ImageProvider? _providerFor(String? url) => url == null
      ? null
      : CachedNetworkImageProvider(
          url,
          cacheManager: CoverCacheManager.instance,
        );

  void _measure(ImageProvider? provider) {
    if (provider == _provider) return;
    _provider = provider;
    if (provider == null) return;
    averageLuminance(provider).then((value) {
      if (!mounted || provider != _provider || value == null) return;
      setState(() => _luminance = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final id = widget.episodeId;
    final reference = id == null ? null : ref.watch(playerPictureProvider(id));
    final ImageProvider? provider;
    if (reference != null && ChapterImageStore.isLocal(reference)) {
      final file = ref.watch(chapterImageFileProvider(reference)).value;
      provider = file == null ? null : FileImage(file);
    } else {
      provider = _providerFor(reference ?? widget.coverUrl);
    }
    _measure(provider);

    final luminance = _luminance;
    final light = luminance != null && luminance > backdropLightThreshold;
    final adapted = provider == null || luminance == null
        ? base
        : backdropTheme(base, backdropForeground(luminance));
    return Stack(
      fit: StackFit.expand,
      children: [
        // Plain surface under everything (no picture, or while it loads).
        ColoredBox(color: base.colorScheme.surface),
        if (provider != null)
          // Painted once (repaint boundary), a small decode scaled up and
          // blurred: cheap on weak phones, nothing to do while scrolling.
          RepaintBoundary(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: SizedBox.expand(
                key: ValueKey(provider),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 24,
                        sigmaY: 24,
                        tileMode: TileMode.mirror,
                      ),
                      child: Image(
                        image: ResizeImage(provider, width: 96),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stack) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    // A veil toward the text color's opposite (see the
                    // constants above), so even a medium picture keeps the
                    // text readable.
                    ColoredBox(
                      color: light
                          ? Colors.white.withValues(alpha: backdropLightVeil)
                          : Colors.black.withValues(alpha: backdropDarkVeil),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Theme(
          data: adapted,
          child: Builder(
            builder: (context) => widget.builder(context, adapted),
          ),
        ),
      ],
    );
  }
}
