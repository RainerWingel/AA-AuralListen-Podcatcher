import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../audio/audio_providers.dart';
import '../../audio/auto_sleep_timer.dart';
import '../../audio/sleep_timer.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';
import '../player/chapters_and_bookmarks.dart';
import 'settings_screen.dart';

/// Name of a sleep timer choice ("30 Minuten", "Bis Ende der Folge").
String sleepTimerName(AppLocalizations l10n, SleepTimer timer) =>
    switch (timer) {
      SleepTimerAfter(:final duration) => l10n.sleepTimerMinutes(
        duration.inMinutes,
      ),
      SleepTimerAtEpisodeEnd() => l10n.sleepTimerEpisodeEnd,
      SleepTimerOff() => l10n.sleepTimerOff,
    };

/// Asks for a time; null = cancelled. Tests replace it (Flutter's dialog
/// cannot be typed into reliably with the test font and settings).
typedef TimePicker = Future<TimeOfDay?> Function(
  BuildContext context,
  TimeOfDay initial,
  String title,
);

/// Flutter's time picker with the dial, as usual on Android (its keyboard
/// layout breaks with a font size below normal: the height is scaled below
/// its own minimum).
final timePickerProvider = Provider<TimePicker>(
  (ref) =>
      (context, initial, title) => showTimePicker(
        context: context,
        initialTime: initial,
        helpText: title,
      ),
);

/// "22:00" in the phone's time format.
String formatTimeOfDay(BuildContext context, int minutes) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// "6 Std. 30 Min.", "6 Std." or "45 Min.".
String _formatLength(AppLocalizations l10n, Duration length) {
  final hours = length.inHours;
  final minutes = length.inMinutes.remainder(60);
  if (hours == 0) return l10n.durationMinutes(minutes);
  if (minutes == 0) return l10n.durationHours(hours);
  return l10n.durationHoursMinutes(hours, minutes);
}

String autoSleepModeName(AppLocalizations l10n, AutoSleepMode mode) =>
    switch (mode) {
      AutoSleepMode.off => l10n.autoSleepModeOff,
      AutoSleepMode.daily => l10n.autoSleepModeDaily,
      AutoSleepMode.weekdays => l10n.autoSleepModeWeekdays,
    };

/// Optionen → Auto-Sleep-Timer (user wish 2026-11-12, docs/playback.md): a
/// Play in the app inside a night window starts the sleep timer. Every valid
/// change is saved at once; an invalid one is refused with a message at the
/// field and the old value stays.
class AutoSleepScreen extends ConsumerWidget {
  const AutoSleepScreen({super.key});

  static const modeKey = ValueKey('auto-sleep-mode');
  static const durationKey = ValueKey('auto-sleep-duration');

  static Future<void> _save(WidgetRef ref, AutoSleepSchedule schedule) => ref
      .read(settingsRepositoryProvider)
      .set(SettingsKeys.autoSleep, schedule.encode());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final schedule = ref.watch(autoSleepScheduleProvider).value;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.autoSleepTitle)),
      body: schedule == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SegmentedButton<AutoSleepMode>(
                    key: modeKey,
                    segments: [
                      for (final mode in AutoSleepMode.values)
                        ButtonSegment(
                          value: mode,
                          label: Text(autoSleepModeName(l10n, mode)),
                        ),
                    ],
                    selected: {schedule.mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (v) =>
                        _save(ref, _switchMode(schedule, v.single)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    l10n.autoSleepIntro,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                if (schedule.mode != AutoSleepMode.off) ...[
                  ListTile(
                    key: durationKey,
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l10n.autoSleepDuration),
                    subtitle: Text(sleepTimerName(l10n, schedule.timer)),
                    onTap: () async {
                      final chosen = await SleepTimerButton.pick(
                        context,
                        current: schedule.timer,
                        offChoice: false,
                        title: l10n.autoSleepDuration,
                      );
                      if (chosen == null || chosen is SleepTimerOff) return;
                      await _save(ref, schedule.copyWith(timer: chosen));
                    },
                  ),
                  if (schedule.mode == AutoSleepMode.daily) ...[
                    SettingsSectionHeader(l10n.autoSleepWindow),
                    _WindowEditor(
                      key: const ValueKey('auto-sleep-daily'),
                      window: schedule.daily,
                      onChanged: (w) => _save(ref, schedule.copyWith(daily: w)),
                    ),
                  ] else ...[
                    SettingsSectionHeader(l10n.autoSleepWindowsPerDay),
                    if (schedule.neverStarts)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Text(
                          l10n.autoSleepAllDaysOff,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    for (var i = 0; i < DateTime.daysPerWeek; i++)
                      _DayEditor(
                        key: ValueKey('auto-sleep-day-$i'),
                        dayName: weekdayName(context, i),
                        window: schedule.weekdays[i],
                        check: (w) =>
                            _overlapError(context, schedule.withDay(i, w), i),
                        onChanged: (w) => _save(ref, schedule.withDay(i, w)),
                        onCopyToAll: () async {
                          final source = schedule.weekdays[i];
                          await _save(
                            ref,
                            schedule.copyWith(
                              weekdays: [
                                for (final w in schedule.weekdays)
                                  w.copyWith(
                                    start: source.start,
                                    end: source.end,
                                  ),
                              ],
                            ),
                          );
                          if (!context.mounted) return;
                          showInfoSnackBar(
                            ScaffoldMessenger.of(context),
                            l10n.autoSleepCopiedToAll(weekdayName(context, i)),
                          );
                        },
                      ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      l10n.autoSleepMidnightHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  /// Switching to "Nach Wochentag" for the first time: every day starts
  /// with the window chosen under "Ein" – nothing typed in is lost.
  static AutoSleepSchedule _switchMode(
    AutoSleepSchedule schedule,
    AutoSleepMode mode,
  ) {
    final untouched = schedule.weekdays.every(
      (w) => w == AutoSleepWindow.standard,
    );
    return schedule.copyWith(
      mode: mode,
      weekdays: mode == AutoSleepMode.weekdays && untouched
          ? List.filled(DateTime.daysPerWeek, schedule.daily)
          : null,
    );
  }

  /// Message if day [index] of [candidate] would overlap a neighbouring
  /// day – one night with two beginnings ("Abbrechen" would not hold).
  static String? _overlapError(
    BuildContext context,
    AutoSleepSchedule candidate,
    int index,
  ) {
    final other = candidate.overlappingDay(index);
    if (other == null) return null;
    final window = candidate.weekdays[other];
    return AppLocalizations.of(context).autoSleepOverlapError(
      weekdayName(context, other),
      '${formatTimeOfDay(context, window.start)}–'
      '${formatTimeOfDay(context, window.end)}',
    );
  }

  /// Weekday name in the UI language; [index] 0 = Monday.
  static String weekdayName(BuildContext context, int index) =>
      // 2024-01-01 was a Monday.
      DateFormat.EEEE(Localizations.localeOf(context).toString())
          .format(DateTime(2024, 1, 1 + index));
}

/// One weekday: switch, and the window while it is on.
class _DayEditor extends StatelessWidget {
  const _DayEditor({
    required this.dayName,
    required this.window,
    required this.check,
    required this.onChanged,
    required this.onCopyToAll,
    super.key,
  });

  final String dayName;
  final AutoSleepWindow window;

  /// Why a changed window of this day is refused (overlap), or null.
  final String? Function(AutoSleepWindow changed) check;
  final ValueChanged<AutoSleepWindow> onChanged;
  final VoidCallback onCopyToAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: Text(dayName),
          value: window.enabled,
          onChanged: (on) {
            final changed = window.copyWith(enabled: on);
            // Switching a day on can make it overlap a neighbour.
            if (check(changed) case final error?) {
              showInfoSnackBar(ScaffoldMessenger.of(context), error);
              return;
            }
            onChanged(changed);
          },
        ),
        if (window.enabled) ...[
          _WindowEditor(window: window, check: check, onChanged: onChanged),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: onCopyToAll,
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: Text(l10n.autoSleepCopyToAll),
              ),
            ),
          ),
        ],
        const Divider(height: 1),
      ],
    );
  }
}

/// "Von" and "Bis" of one window and its length. A change that would make
/// the window invalid is not passed on; the reason is shown below the times
/// instead.
class _WindowEditor extends ConsumerStatefulWidget {
  const _WindowEditor({
    required this.window,
    required this.onChanged,
    this.check,
    super.key,
  });

  final AutoSleepWindow window;
  final ValueChanged<AutoSleepWindow> onChanged;

  /// Further reasons to refuse a change (overlap with another day).
  final String? Function(AutoSleepWindow changed)? check;

  @override
  ConsumerState<_WindowEditor> createState() => _WindowEditorState();
}

class _WindowEditorState extends ConsumerState<_WindowEditor> {
  String? _error;

  @override
  void didUpdateWidget(_WindowEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Changed from elsewhere ("Auf alle Tage übernehmen"): old news.
    if (oldWidget.window != widget.window) _error = null;
  }

  static TimeOfDay _time(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  Future<void> _pick({required bool start}) async {
    final l10n = AppLocalizations.of(context);
    final window = widget.window;
    final picked = await ref.read(timePickerProvider)(
      context,
      _time(start ? window.start : window.end),
      start ? l10n.autoSleepPickStart : l10n.autoSleepPickEnd,
    );
    if (picked == null || !mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    final changed = start
        ? window.copyWith(start: minutes)
        : window.copyWith(end: minutes);
    final error = switch (changed.error) {
      AutoSleepWindowError.sameTime => l10n.autoSleepSameTimeError,
      null => widget.check?.call(changed),
    };
    setState(() => _error = error);
    if (error == null) widget.onChanged(changed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String show(int minutes) => formatTimeOfDay(context, minutes);
    final window = widget.window;
    final length = _formatLength(l10n, window.length);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pick(start: true),
                icon: const Icon(Icons.bedtime_outlined, size: 18),
                label: Text(l10n.autoSleepFrom(show(window.start))),
              ),
              OutlinedButton.icon(
                onPressed: () => _pick(start: false),
                icon: const Icon(Icons.wb_twilight, size: 18),
                label: Text(l10n.autoSleepUntil(show(window.end))),
              ),
              Text(
                window.crossesMidnight
                    ? l10n.autoSleepSpanNextDay(length)
                    : l10n.autoSleepSpanSameDay(length),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
