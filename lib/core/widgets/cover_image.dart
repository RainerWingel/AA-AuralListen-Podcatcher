import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/storage/cover_cache.dart';

/// Square podcast/episode cover from the bounded disk cache.
/// Decodes the image only at display size to keep RAM usage low (docs/eviction.md).
class CoverImage extends StatelessWidget {
  const CoverImage({required this.url, required this.size, super.key});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final decodeWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(size < 80 ? 6 : 10),
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? const _Placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                cacheManager: CoverCacheManager.instance,
                memCacheWidth: decodeWidth,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, url) => const _Placeholder(),
                errorWidget: (context, url, error) => const _Placeholder(),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.podcasts, color: colors.onSurfaceVariant),
    );
  }
}
