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

/// One night of the Auto-Sleep-Timer: a window – or several windows of
/// neighbouring days that overlap, merged – from [start] to [end].
typedef AutoSleepNight = ({DateTime start, DateTime end});

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

  /// How long the window is (shown next to the times, so swapped times stand
  /// out). Wall-clock length: a daylight-saving night is an hour off.
  Duration get length => Duration(
    minutes: crossesMidnight ? end + minutesPerDay - start : end - start,
  );

  /// Null if the window may be saved.
  AutoSleepWindowError? get error =>
      start == end ? AutoSleepWindowError.sameTime : null;

  bool get _inRange =>
      start >= 0 && start < minutesPerDay && end >= 0 && end < minutesPerDay;

  bool get _active => enabled && error == null && _inRange;

  /// This window on [day] (its date only); null if switched off or invalid.
  /// Built from the calendar date and wall-clock time, so a daylight-saving
  /// change during the night does not shift the end.
  AutoSleepNight? on(DateTime day) {
    if (!_active) return null;
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
    return (start: from, end: to);
  }

  /// This window (of one day) runs into [next] (of the following day): it
  /// passes midnight and ends after [next] begins. Such input is refused –
  /// the two would be one night with two beginnings.
  bool runsInto(AutoSleepWindow next) =>
      _active && next._active && crossesMidnight && end > next.start;

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

  /// The night [now] lies in, or null if none. A window past midnight
  /// belongs to the day it starts. Windows of neighbouring days that
  /// overlap (refused in the UI, but possible from old data) count as one
  /// night, so "switched off for tonight" lasts until its very end.
  AutoSleepNight? nightAt(DateTime now) {
    if (mode == AutoSleepMode.off) return null;
    final windows = <AutoSleepNight>[
      // A week back covers any chain of overlapping windows that is not
      // endless; tomorrow's window may lengthen tonight's. In order of
      // their start (each starts on its own day).
      for (var back = DateTime.daysPerWeek; back >= -1; back--)
        ?_windowOn(DateTime(now.year, now.month, now.day - back)),
    ];
    bool contains(AutoSleepNight night) =>
        !now.isBefore(night.start) && now.isBefore(night.end);
    AutoSleepNight? night;
    for (final window in windows) {
      if (night != null && window.start.isBefore(night.end)) {
        if (window.end.isAfter(night.end)) {
          night = (start: night.start, end: window.end);
        }
      } else {
        if (night != null && contains(night)) return night;
        night = window;
      }
    }
    return night != null && contains(night) ? night : null;
  }

  AutoSleepNight? _windowOn(DateTime day) => windowFor(day.weekday).on(day);

  /// Per weekday ([index] 0 = Monday): the day whose window overlaps that of
  /// day [index] – the previous or the next one – or null.
  int? overlappingDay(int index) {
    final previous = (index + DateTime.daysPerWeek - 1) % DateTime.daysPerWeek;
    final next = (index + 1) % DateTime.daysPerWeek;
    if (weekdays[previous].runsInto(weekdays[index])) return previous;
    if (weekdays[index].runsInto(weekdays[next])) return next;
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
