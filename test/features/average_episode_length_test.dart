import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/features/subscriptions/podcast_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Episode episode(int? durationMs, {DateTime? pubDate}) => Episode(
    id: 1,
    podcastId: 1,
    guid: 'g',
    title: 't',
    audioUrl: 'https://example.com/a.mp3',
    durationMs: durationMs,
    pubDate: pubDate,
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

  test('only the 70 newest episodes count', () {
    final old = [
      for (var i = 0; i < 30; i++)
        episode(600000, pubDate: DateTime.utc(2020, 1, 1 + i)), // 10 min
    ];
    final recent = [
      for (var i = 0; i < 70; i++)
        episode(3600000, pubDate: DateTime.utc(2026, 1, 1 + i)), // 60 min
    ];
    // Order of the list does not matter (e.g. serial podcasts).
    expect(averageEpisodeLength([...old, ...recent]), const Duration(hours: 1));
    expect(averageOf, 70);
  });
}
