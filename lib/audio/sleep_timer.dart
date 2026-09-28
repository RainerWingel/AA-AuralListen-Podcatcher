/// Sleep timer setting (docs/playback.md) – in memory only.
sealed class SleepTimer {
  const SleepTimer();
}

/// No sleep timer.
class SleepTimerOff extends SleepTimer {
  const SleepTimerOff();
}

/// Pause after [duration] of playing time (paused time does not count).
class SleepTimerAfter extends SleepTimer {
  const SleepTimerAfter(this.duration);

  final Duration duration;
}

/// Pause at the end of the current episode (no next playlist episode).
class SleepTimerAtEpisodeEnd extends SleepTimer {
  const SleepTimerAtEpisodeEnd();
}

/// What the UI shows: the chosen timer and, for [SleepTimerAfter], the
/// playing time left.
class SleepTimerState {
  const SleepTimerState(this.timer, {this.remaining});

  static const off = SleepTimerState(SleepTimerOff());

  final SleepTimer timer;
  final Duration? remaining;

  bool get isActive => timer is! SleepTimerOff;
}
