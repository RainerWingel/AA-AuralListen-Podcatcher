import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../data/settings_keys.dart';
import 'battery_optimization.dart';
import 'podcast_audio_handler.dart';
import 'sleep_timer.dart';

/// The single player instance. Created in main() via AudioService.init and
/// injected with an override (tests inject one with a fake engine).
final audioHandlerProvider = Provider<PodcastAudioHandler>(
  (ref) => throw UnimplementedError('Overridden in main() and in tests'),
);

/// What is playing / was played last (null = mini player hidden).
/// What the player shows. [MediaItem] compares by id only, so an update of
/// the same episode (corrected duration, playlist offered/active) would be
/// swallowed by Riverpod; this wrapper has no `==` – every update counts.
class PlayerItem {
  const PlayerItem(this.mediaItem);

  final MediaItem? mediaItem;
}

final mediaItemProvider = StreamProvider<PlayerItem>(
  (ref) => ref.watch(audioHandlerProvider).mediaItem.map(PlayerItem.new),
);

final playbackStateProvider = StreamProvider<PlaybackState>(
  (ref) => ref.watch(audioHandlerProvider).playbackState,
);

/// Live position for progress bars; only listened to while a player UI is visible.
final positionProvider = StreamProvider.autoDispose<Duration>(
  (ref) => ref.watch(audioHandlerProvider).positionStream,
);

/// Start times (ms) of the chapters marked "Skip" (in memory only).
final skippedChaptersProvider = StreamProvider.autoDispose
    .family<Set<int>, int>(
      (ref, episodeId) =>
          ref.watch(audioHandlerProvider).chapterSkips.watch(episodeId),
    );

/// One occurrence of a playback problem. Deliberately without `==`: the
/// same problem twice in a row must show the info box twice (a provider only
/// notifies listeners when its value changes).
class PlaybackProblemNotice {
  PlaybackProblemNotice(this.problem);

  final PlaybackProblem problem;
}

/// Playback problems to show as an info box (hang detection, load errors).
final playbackProblemsProvider =
    StreamProvider.autoDispose<PlaybackProblemNotice>(
      (ref) => ref
          .watch(audioHandlerProvider)
          .problems
          .map(PlaybackProblemNotice.new),
    );

/// Sleep timer setting; changes only (the countdown is computed on rebuild).
final sleepTimerProvider = StreamProvider.autoDispose<SleepTimerState>(
  (ref) => ref.watch(audioHandlerProvider).sleepTimerStream,
);

/// Battery optimisation of the app (fake in tests).
final batteryOptimizationProvider = Provider<BatteryOptimization>(
  (ref) => const AndroidBatteryOptimization(),
);

/// Whether the app is "Nicht eingeschränkt"; invalidate after returning
/// from the system dialog or settings.
final batteryExemptProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(batteryOptimizationProvider).isExempt(),
);

final globalBoostProvider = StreamProvider.autoDispose<double>(
  (ref) => ref
      .watch(settingsRepositoryProvider)
      .watch(SettingsKeys.boostDb)
      .map((value) => double.tryParse(value ?? '') ?? 0),
);

typedef BoostSetting = ({double db, bool perPodcast});

/// Effective boost for a podcast: its own value, else the global default.
final boostSettingProvider = Provider.autoDispose.family<BoostSetting, int>((
  ref,
  podcastId,
) {
  final own = ref.watch(podcastProvider(podcastId)).value?.boostDb;
  final global = ref.watch(globalBoostProvider).value ?? 0;
  return (db: own ?? global, perPodcast: own != null);
});
