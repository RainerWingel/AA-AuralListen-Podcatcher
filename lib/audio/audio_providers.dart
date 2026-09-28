import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../data/settings_keys.dart';
import 'battery_optimization.dart';
import 'podcast_audio_handler.dart';

/// The single player instance. Created in main() via AudioService.init and
/// injected with an override (tests inject one with a fake engine).
final audioHandlerProvider = Provider<PodcastAudioHandler>(
  (ref) => throw UnimplementedError('Overridden in main() and in tests'),
);

/// What is playing / was played last (null = mini player hidden).
final mediaItemProvider = StreamProvider<MediaItem?>(
  (ref) => ref.watch(audioHandlerProvider).mediaItem,
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

/// Playback problems to show as an info box (hang detection, load errors).
final playbackProblemsProvider = StreamProvider.autoDispose<PlaybackProblem>(
  (ref) => ref.watch(audioHandlerProvider).problems,
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
