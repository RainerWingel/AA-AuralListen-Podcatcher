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
