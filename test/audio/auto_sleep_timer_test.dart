import 'package:aapodcastguru/audio/auto_sleep_timer.dart';
import 'package:aapodcastguru/audio/sleep_timer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Window logic of the Auto-Sleep-Timer (docs/playback.md). All times are
/// local wall-clock times, so the tests hold in every time zone; the
/// daylight-saving cases matter in Europe (run with TZ=Europe/Berlin).
/// Start of the night [now] lies in – it tells the nights apart.
DateTime? startAt(AutoSleepSchedule schedule, DateTime now) =>
    schedule.nightAt(now)?.start;

void main() {
  AutoSleepWindow window(int startHour, int endHour, {bool on = true}) =>
      AutoSleepWindow(start: startHour * 60, end: endHour * 60, enabled: on);

  group('every day ("Ein"), 22:00–04:00', () {
    final schedule = AutoSleepSchedule(mode: AutoSleepMode.daily);
    final thursday = DateTime(2026, 11, 12, 22);

    test('starts at 22:00, ends before 04:00 next morning', () {
      expect(startAt(schedule, DateTime(2026, 11, 12, 21, 59)), isNull);
      expect(startAt(schedule, DateTime(2026, 11, 12, 22)), thursday);
      expect(startAt(schedule, DateTime(2026, 11, 12, 23, 59)), thursday);
      expect(startAt(schedule, DateTime(2026, 11, 13)), thursday);
      expect(startAt(schedule, DateTime(2026, 11, 13, 3, 59)), thursday);
      expect(startAt(schedule, DateTime(2026, 11, 13, 4)), isNull);
      expect(startAt(schedule, DateTime(2026, 11, 13, 12)), isNull);
    });

    test('before and after midnight are the same night', () {
      expect(
        startAt(schedule, DateTime(2026, 11, 12, 23)),
        startAt(schedule, DateTime(2026, 11, 13, 2)),
      );
      expect(
        startAt(schedule, DateTime(2026, 11, 13, 23)),
        isNot(startAt(schedule, DateTime(2026, 11, 13, 2))),
      );
    });

    test('over the turn of the month and year', () {
      final newYearsEve = DateTime(2026, 12, 31, 22);
      expect(startAt(schedule, DateTime(2027, 1, 1, 3)), newYearsEve);
      expect(
        startAt(schedule, DateTime(2026, 3, 1, 1)),
        DateTime(2026, 2, 28, 22),
      );
    });

    test('mode "Aus" never matches', () {
      final off = schedule.copyWith(mode: AutoSleepMode.off);
      expect(startAt(off, DateTime(2026, 11, 12, 23)), isNull);
    });
  });

  test('a window during the day does not reach into the next day', () {
    final schedule = AutoSleepSchedule(
      mode: AutoSleepMode.daily,
      daily: window(13, 15),
    );
    expect(
      startAt(schedule, DateTime(2026, 11, 12, 14)),
      DateTime(2026, 11, 12, 13),
    );
    expect(startAt(schedule, DateTime(2026, 11, 12, 15)), isNull);
    expect(startAt(schedule, DateTime(2026, 11, 12, 12, 59)), isNull);
  });

  test('a window from midnight belongs to that day', () {
    final schedule = AutoSleepSchedule(
      mode: AutoSleepMode.daily,
      daily: window(0, 5),
    );
    expect(
      startAt(schedule, DateTime(2026, 11, 13, 1)),
      DateTime(2026, 11, 13),
    );
    expect(startAt(schedule, DateTime(2026, 11, 12, 23)), isNull);
  });

  group('per weekday', () {
    // Monday off, Friday 23–05, Saturday off, other days 22–04.
    final schedule = AutoSleepSchedule(mode: AutoSleepMode.weekdays)
        .withDay(DateTime.monday - 1, window(22, 4, on: false))
        .withDay(DateTime.friday - 1, window(23, 5))
        .withDay(DateTime.saturday - 1, window(22, 4, on: false));

    test('the night belongs to the day it starts', () {
      // Saturday 02:00 is still Friday night (Saturday itself is off).
      expect(
        startAt(schedule, DateTime(2026, 11, 14, 2)),
        DateTime(2026, 11, 13, 23),
      );
      expect(startAt(schedule, DateTime(2026, 11, 14, 4, 30)), isNotNull);
      expect(startAt(schedule, DateTime(2026, 11, 14, 5)), isNull);
      // Friday 22:30: Friday's window starts only at 23:00.
      expect(startAt(schedule, DateTime(2026, 11, 13, 22, 30)), isNull);
    });

    test('a day switched off starts nothing that evening', () {
      expect(startAt(schedule, DateTime(2026, 11, 14, 23)), isNull);
      expect(startAt(schedule, DateTime(2026, 11, 15, 2)), isNull);
      // Monday off, but Sunday night reaches into Monday morning.
      expect(
        startAt(schedule, DateTime(2026, 11, 16, 3)),
        DateTime(2026, 11, 15, 22),
      );
      expect(startAt(schedule, DateTime(2026, 11, 16, 23)), isNull);
    });

    test('all days off never starts', () {
      final none = AutoSleepSchedule(
        mode: AutoSleepMode.weekdays,
        weekdays: List.filled(7, window(22, 4, on: false)),
      );
      expect(none.neverStarts, isTrue);
      expect(schedule.neverStarts, isFalse);
      for (var day = 9; day < 16; day++) {
        expect(startAt(none, DateTime(2026, 11, day, 23)), isNull);
      }
    });
  });

  group('overlapping windows of neighbouring days', () {
    // Monday 20:00–06:00 runs into Tuesday 00:00–05:00.
    final overlapping = AutoSleepSchedule(mode: AutoSleepMode.weekdays)
        .withDay(DateTime.monday - 1, window(20, 6))
        .withDay(DateTime.tuesday - 1, window(0, 5));

    test('are found on both days', () {
      expect(overlapping.overlappingDay(DateTime.tuesday - 1), 0);
      expect(overlapping.overlappingDay(DateTime.monday - 1), 1);
      expect(overlapping.overlappingDay(DateTime.wednesday - 1), isNull);
    });

    test('also from Sunday into Monday', () {
      final schedule = AutoSleepSchedule(mode: AutoSleepMode.weekdays)
          .withDay(DateTime.sunday - 1, window(23, 3))
          .withDay(DateTime.monday - 1, window(1, 2));
      expect(schedule.overlappingDay(DateTime.monday - 1), 6);
      expect(schedule.overlappingDay(DateTime.sunday - 1), 0);
    });

    test('touching, switched off or not past midnight is no overlap', () {
      final base = AutoSleepSchedule(mode: AutoSleepMode.weekdays);
      // Monday ends 04:00, Tuesday starts 04:00: two nights.
      expect(
        base
            .withDay(0, window(22, 4))
            .withDay(1, window(4, 6))
            .overlappingDay(1),
        isNull,
      );
      expect(
        base
            .withDay(0, window(20, 6, on: false))
            .withDay(1, window(0, 5))
            .overlappingDay(1),
        isNull,
      );
      expect(
        base
            .withDay(0, window(13, 15))
            .withDay(1, window(0, 5))
            .overlappingDay(1),
        isNull,
      );
      // The same window every day never overlaps ("auf alle Tage").
      for (var i = 0; i < 7; i++) {
        expect(base.overlappingDay(i), isNull);
      }
    });

    test('old data with an overlap counts as one night', () {
      final monday = DateTime(2026, 11, 9, 20);
      final tuesdayMorning = DateTime(2026, 11, 10, 6);
      for (final hour in [23, 25, 29]) {
        final night = overlapping.nightAt(
          DateTime(2026, 11, 9).add(Duration(hours: hour)),
        );
        expect(night?.start, monday, reason: '+$hour h');
        expect(night?.end, tuesdayMorning, reason: '+$hour h');
      }
      expect(overlapping.nightAt(tuesdayMorning), isNull);
    });

    test('a chain lasts until its last window ends', () {
      // Tuesday 05:00–03:00 continues Monday's night until Wednesday 03:00.
      final chain = overlapping.withDay(DateTime.tuesday - 1, window(5, 3));
      final night = chain.nightAt(DateTime(2026, 11, 10, 12));
      expect(night?.start, DateTime(2026, 11, 9, 20));
      expect(night?.end, DateTime(2026, 11, 11, 3));
    });
  });

  test('length of a window', () {
    expect(window(22, 4).length, const Duration(hours: 6));
    expect(window(13, 15).length, const Duration(hours: 2));
    expect(window(4, 22).length, const Duration(hours: 18));
    expect(
      const AutoSleepWindow(start: 0, end: 1).length,
      const Duration(minutes: 1),
    );
  });

  group('daylight saving time (wall-clock times count)', () {
    final schedule = AutoSleepSchedule(mode: AutoSleepMode.daily);

    test('spring: the short night still ends at 04:00', () {
      // Europe: 2026-03-29 02:00 → 03:00.
      final saturday = DateTime(2026, 3, 28, 22);
      expect(startAt(schedule, DateTime(2026, 3, 29, 1, 30)), saturday);
      expect(startAt(schedule, DateTime(2026, 3, 29, 3, 30)), saturday);
      expect(startAt(schedule, DateTime(2026, 3, 29, 4)), isNull);
    });

    test('autumn: the long night still ends at 04:00', () {
      // Europe: 2026-10-25 03:00 → 02:00.
      final saturday = DateTime(2026, 10, 24, 22);
      expect(startAt(schedule, DateTime(2026, 10, 25, 2, 30)), saturday);
      expect(startAt(schedule, DateTime(2026, 10, 25, 3, 59)), saturday);
      expect(startAt(schedule, DateTime(2026, 10, 25, 4)), isNull);
    });

    test('a window may start on the day of the change', () {
      expect(
        startAt(schedule, DateTime(2026, 3, 29, 23)),
        DateTime(2026, 3, 29, 22),
      );
      expect(
        startAt(schedule, DateTime(2026, 10, 26, 1)),
        DateTime(2026, 10, 25, 22),
      );
    });
  });

  group('validation', () {
    test('start and end at the same time is refused', () {
      expect(window(22, 22).error, AutoSleepWindowError.sameTime);
      expect(window(0, 0).error, AutoSleepWindowError.sameTime);
      expect(window(22, 4).error, isNull);
      expect(
        const AutoSleepWindow(start: 0, end: 1).error,
        isNull,
        reason: 'one minute is short, but meaningful',
      );
    });

    test('an invalid window never matches', () {
      final schedule = AutoSleepSchedule(
        mode: AutoSleepMode.daily,
        daily: window(22, 22),
      );
      expect(startAt(schedule, DateTime(2026, 11, 12, 22)), isNull);
      expect(startAt(schedule, DateTime(2026, 11, 12, 3)), isNull);
    });

    test('seven days are required', () {
      expect(
        () => AutoSleepSchedule(weekdays: [window(22, 4)]),
        throwsArgumentError,
      );
    });
  });

  group('stored as JSON', () {
    test('round trip', () {
      final schedule = AutoSleepSchedule(
        mode: AutoSleepMode.weekdays,
        daily: window(21, 3),
        timer: const SleepTimerAtEpisodeEnd(),
      ).withDay(2, window(23, 1, on: false));
      final back = AutoSleepSchedule.decode(schedule.encode());
      expect(back.mode, AutoSleepMode.weekdays);
      expect(back.daily, window(21, 3));
      expect(back.weekdays, schedule.weekdays);
      expect(back.timer, isA<SleepTimerAtEpisodeEnd>());

      final minutes = AutoSleepSchedule.decode(
        schedule
            .copyWith(timer: const SleepTimerAfter(Duration(minutes: 90)))
            .encode(),
      );
      expect(
        (minutes.timer as SleepTimerAfter).duration,
        const Duration(minutes: 90),
      );
    });

    test('missing or broken values fall back to the defaults', () {
      for (final stored in [null, '', 'nonsense', '[]', '{"mode": 3}']) {
        final schedule = AutoSleepSchedule.decode(stored);
        // A fresh app: on, every night 22:00–04:00, 30 minutes.
        expect(schedule.mode, AutoSleepMode.daily, reason: '$stored');
        expect(schedule.daily, AutoSleepWindow.standard);
        expect(schedule.timer, AutoSleepSchedule.defaultTimer);
      }
      final odd = AutoSleepSchedule.decode(
        '{"mode":"daily","daily":{"start":9999,"end":-5},'
        '"days":[1,2],"timer":0}',
      );
      expect(odd.mode, AutoSleepMode.daily);
      expect(odd.daily, AutoSleepWindow.standard);
      expect(odd.weekdays, everyElement(AutoSleepWindow.standard));
      expect(odd.timer, AutoSleepSchedule.defaultTimer);
    });
  });
}
