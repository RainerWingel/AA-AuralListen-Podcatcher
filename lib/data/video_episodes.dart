import 'db/app_database.dart';

/// A video enclosure (`video/mp4`, `video/quicktime` …). Only for marking
/// and download rules: whether the player shows a picture is decided by the
/// file itself (docs/playback.md "Video").
bool isVideoMimeType(String? mimeType) =>
    mimeType?.toLowerCase().startsWith('video/') ?? false;

extension EpisodeVideo on Episode {
  bool get isVideo => isVideoMimeType(audioMimeType);
}
