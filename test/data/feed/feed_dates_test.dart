import 'package:aapodcastguru/data/feed/feed_dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseFeedDate', () {
    final cases = <String, DateTime>{
      'Tue, 10 Jun 2025 04:00:00 +0000': DateTime.utc(2025, 6, 10, 4),
      'Tue, 10 Jun 2025 04:00:00 +0200': DateTime.utc(2025, 6, 10, 2),
      'Tue, 10 Jun 2025 04:00:00 -05:30': DateTime.utc(2025, 6, 10, 9, 30),
      'Tue, 10 Jun 2025 04:00:00 GMT': DateTime.utc(2025, 6, 10, 4),
      'Tue, 10 Jun 2025 04:00:00 PDT': DateTime.utc(2025, 6, 10, 11),
      'Tue, 10 Jun 2025 04:00:00 CEST': DateTime.utc(2025, 6, 10, 2),
      '3 Jun 2025 10:30 GMT': DateTime.utc(2025, 6, 3, 10, 30),
      'Tue,  3 June 2025 10:30:00 +0000': DateTime.utc(2025, 6, 3, 10, 30),
      'Tue, 10 Jun 25 04:00:00 +0000': DateTime.utc(2025, 6, 10, 4),
      'Tue, 10 Jun 2025 04:00:00': DateTime.utc(2025, 6, 10, 4),
      '2025-06-10T04:00:00Z': DateTime.utc(2025, 6, 10, 4),
      '2025-06-10T04:00:00+02:00': DateTime.utc(2025, 6, 10, 2),
    };
    cases.forEach((input, expected) {
      test(input, () => expect(parseFeedDate(input), expected));
    });

    test('returns null for garbage', () {
      expect(parseFeedDate(null), isNull);
      expect(parseFeedDate(''), isNull);
      expect(parseFeedDate('gestern'), isNull);
      expect(parseFeedDate('10 Foo 2025 04:00:00 GMT'), isNull);
    });
  });

  group('parseFeedDuration', () {
    test('parses all common formats', () {
      expect(parseFeedDuration('3600'), const Duration(hours: 1));
      expect(parseFeedDuration('90.5'), const Duration(milliseconds: 90500));
      expect(
        parseFeedDuration('59:30'),
        const Duration(minutes: 59, seconds: 30),
      );
      expect(
        parseFeedDuration('1:02:03'),
        const Duration(hours: 1, minutes: 2, seconds: 3),
      );
    });

    test('returns null for invalid or zero values', () {
      expect(parseFeedDuration(null), isNull);
      expect(parseFeedDuration('0'), isNull);
      expect(parseFeedDuration('abc'), isNull);
      expect(parseFeedDuration('1:2:3:4'), isNull);
    });
  });
}
