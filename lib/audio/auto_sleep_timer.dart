import 'dart:convert';

import 'sleep_timer.dart';

/// Optionen → Auto-Sleep-Timer (docs/playback.md): off, the same night
/// window every day, or one window per weekday.
enum AutoSleepMode {
  off,
  daily,
  weekdays;

  static AutoSleepMode fromName(Object? name) => values.firstWhere(
    (m) => m.name == name,
    orElse: () => AutoSleepSchedule.defaultMode,
  );
}

/// Why a window cannot be saved.
enum AutoSleepWindowError {
  /// Start and end are the same time – a window of length zero.
  sameTime,
}

/// The time span in which a Play in the app starts the sleep timer.
/// [start] and [end] are minutes after midnight (local wall-clock time);
/// [end] itself no longer belongs to it. An end at or before the start
/// means the window runs past midnight – it belongs to the day it starts.
class AutoSleepWindow {
  const AutoSleepWindow({
    required this.start,
    required this.end,
    this.enabled = true,
  });

  /// 22:00 to 04:00 (user request).
  static const standard = AutoSleepWindow(start: 22 * 60, end: 4 * 60);

  static const minutesPerDay = 24 * 60;

  final int start;
  final int end;

  /// Only used per weekday: the day can be switched off on its own.
  final bool enabled;

  bool get crossesMidnight => end < start;

  /// Null if the window may be saved.
  AutoSleepWindowError? get error =>
      start == end ? AutoSleepWindowError.sameTime : null;

  bool get _inRange =>
      start >= 0 && start < minutesPerDay && end >= 0 && end < minutesPerDay;

  /// Start of this window on [day] (its date only) if [now] lies inside it.
  /// Built from the calendar date and wall-clock time, so a daylight-saving
  /// change during the night does not shift the end.
  DateTime? startIfInside(DateTime day, DateTime now) {
    if (!enabled || error != null || !_inRange) return null;
    final from = DateTime(
      day.year,
      day.month,
      day.day,
      start ~/ 60,
      start % 60,
    );
    final to = DateTime(
      day.year,
      day.month,
      day.day + (crossesMidnight ? 1 : 0),
      end ~/ 60,
      end % 60,
    );
    return !now.isBefore(from) && now.isBefore(to) ? from : null;
  }

  AutoSleepWindow copyWith({int? start, int? end, bool? enabled}) =>
      AutoSleepWindow(
        start: start ?? this.start,
        end: end ?? this.end,
        enabled: enabled ?? this.enabled,
      );

  Map<String, Object> toJson() => {'start': start, 'end': end, 'on': enabled};

  static AutoSleepWindow fromJson(Object? json) {
    if (json is! Map) return standard;
    final start = json['start'];
    final end = json['end'];
    final window = AutoSleepWindow(
      start: start is int ? start : standard.start,
      end: end is int ? end : standard.end,
      enabled: json['on'] != false,
    );
    return window._inRange ? window : standard;
  }

  @override
  bool operator ==(Object other) =>
      other is AutoSleepWindow &&
      other.start == start &&
      other.end == end &&
      other.enabled == enabled;

  @override
  int get hashCode => Object.hash(start, end, enabled);
}

/// The whole setting, stored as JSON under `SettingsKeys.autoSleep`.
class AutoSleepSchedule {
  AutoSleepSchedule({
    this.mode = defaultMode,
    this.daily = AutoSleepWindow.standard,
    List<AutoSleepWindow>? weekdays,
    this.timer = defaultTimer,
  }) : weekdays = List.unmodifiable(
         weekdays ?? List.filled(DateTime.daysPerWeek, daily),
       ) {
    if (this.weekdays.length != DateTime.daysPerWeek) {
      throw ArgumentError.value(weekdays, 'weekdays', 'needs seven days');
    }
  }

  /// A fresh app (and an update from 1.3.6 or older): on, every night
  /// 22:00–04:00 (user wish 2026-11-12).
  static const defaultMode = AutoSleepMode.daily;

  /// 30 minutes, like the middle choice of the manual sleep timer.
  static const defaultTimer = SleepTimerAfter(Duration(minutes: 30));

  final AutoSleepMode mode;

  /// Window for [AutoSleepMode.daily].
  final AutoSleepWindow daily;

  /// Windows for [AutoSleepMode.weekdays]; index 0 = Monday
  /// ([DateTime.monday] − 1) … 6 = Sunday.
  final List<AutoSleepWindow> weekdays;

  /// The timer that is started: [SleepTimerAfter] or
  /// [SleepTimerAtEpisodeEnd] (never off).
  final SleepTimer timer;

  /// Window that applies to nights starting on [weekday] ([DateTime.monday]
  /// … [DateTime.sunday]).
  AutoSleepWindow windowFor(int weekday) => switch (mode) {
    AutoSleepMode.off => const AutoSleepWindow(start: 0, end: 0),
    AutoSleepMode.daily => daily,
    AutoSleepMode.weekdays => weekdays[weekday - 1],
  };

  /// Start of the window [now] lies in, or null if none. The start tells
  /// the nights apart ("cancelled tonight" must not last until tomorrow).
  /// A window past midnight belongs to the day it starts, so yesterday's
  /// window is checked too.
  DateTime? windowStartAt(DateTime now) {
    if (mode == AutoSleepMode.off) return null;
    for (final back in const [0, 1]) {
      final day = DateTime(now.year, now.month, now.day - back);
      final start = windowFor(day.weekday).startIfInside(day, now);
      if (start != null) return start;
    }
    return null;
  }

  /// Per weekday all seven days are switched off: it never starts.
  bool get neverStarts =>
      mode == AutoSleepMode.weekdays && weekdays.every((w) => !w.enabled);

  AutoSleepSchedule copyWith({
    AutoSleepMode? mode,
    AutoSleepWindow? daily,
    List<AutoSleepWindow>? weekdays,
    SleepTimer? timer,
  }) => AutoSleepSchedule(
    mode: mode ?? this.mode,
    daily: daily ?? this.daily,
    weekdays: weekdays ?? this.weekdays,
    timer: timer ?? this.timer,
  );

  /// [weekdays] with day [index] (0 = Monday) replaced.
  AutoSleepSchedule withDay(int index, AutoSleepWindow window) =>
      copyWith(weekdays: [...weekdays]..[index] = window);

  String encode() => jsonEncode({
    'mode': mode.name,
    'daily': daily.toJson(),
    'days': [for (final w in weekdays) w.toJson()],
    'timer': switch (timer) {
      SleepTimerAfter(:final duration) => duration.inMinutes,
      _ => 'end',
    },
  });

  /// Reads the stored value; missing or broken → defaults ([defaultMode]).
  static AutoSleepSchedule decode(String? stored) {
    if (stored == null) return AutoSleepSchedule();
    final Object? json;
    try {
      json = jsonDecode(stored);
    } on FormatException {
      return AutoSleepSchedule();
    }
    if (json is! Map) return AutoSleepSchedule();
    final daily = AutoSleepWindow.fromJson(json['daily']);
    final days = json['days'];
    final timer = json['timer'];
    return AutoSleepSchedule(
      mode: AutoSleepMode.fromName(json['mode']),
      daily: daily,
      weekdays: days is List && days.length == DateTime.daysPerWeek
          ? [for (final d in days) AutoSleepWindow.fromJson(d)]
          : null,
      timer: switch (timer) {
        'end' => const SleepTimerAtEpisodeEnd(),
        final int minutes when minutes > 0 => SleepTimerAfter(
          Duration(minutes: minutes),
        ),
        _ => defaultTimer,
      },
    );
  }
}
