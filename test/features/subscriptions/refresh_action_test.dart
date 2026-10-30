import 'package:aapodcastguru/features/subscriptions/refresh_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('moved message names up to three podcasts', () {
    expect(movedPodcastNames(['A']), 'A');
    expect(movedPodcastNames(['A', 'B', 'C']), 'A, B, C');
    expect(movedPodcastNames(['A', 'B', 'C', 'D']), 'A, B, C, …');
  });
}
