import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/features/subscriptions/podcast_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Episode episode(int? durationMs) => Episode(
    id: 1,
    podcastId: 1,
    guid: 'g',
    title: 't',
    audioUrl: 'https://example.com/a.mp3',
    durationMs: durationMs,
    positionMs: 0,
    status: EpisodeStatus.newEpisode,
    addedAt: DateTime.utc(2026),
  );

  test('average of the known lengths only', () {
    expect(
      averageEpisodeLength([
        episode(60000),
        episode(null),
        episode(0),
        episode(120000),
      ]),
      const Duration(minutes: 1, seconds: 30),
    );
    expect(averageEpisodeLength([episode(null)]), isNull);
    expect(averageEpisodeLength([]), isNull);
  });
}
