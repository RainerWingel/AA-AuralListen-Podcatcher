import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk cache for cover images with hard limits (see docs/eviction.md).
class CoverCacheManager extends CacheManager with ImageCacheManager {
  CoverCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 300,
        ),
      );

  static const key = 'coverCache';

  /// One instance for the whole app; the cache manager keeps its own DB connection.
  static final CoverCacheManager instance = CoverCacheManager._();

  /// Authority of `CoverProvider` (Kotlin, AndroidManifest.xml), which serves
  /// files of this cache to Android Auto.
  static const carAuthority = 'io.github.rainerwingel.aurallisten.covers';

  /// A `content://` address of the cached cover of [url] for Android Auto,
  /// or null when it is not cached – nothing is downloaded for the car.
  Future<Uri?> carCoverUri(String url) async {
    final cached = await getFileFromCache(url);
    if (cached == null) return null;
    return Uri(
      scheme: 'content',
      host: carAuthority,
      pathSegments: [cached.file.basename],
    );
  }
}

/// Lets the repository drop cached covers without depending on Flutter caching code.
abstract interface class CoverCache {
  Future<void> evict(String url);
}

class DefaultCoverCache implements CoverCache {
  const DefaultCoverCache();

  @override
  Future<void> evict(String url) => CoverCacheManager.instance.removeFile(url);
}
