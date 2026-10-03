import 'package:aapodcastguru/audio/audio_providers.dart';
import 'package:aapodcastguru/audio/podcast_audio_handler.dart';
import 'package:aapodcastguru/data/db/app_database.dart';
import 'package:aapodcastguru/data/playback_repository.dart';
import 'package:aapodcastguru/data/settings_repository.dart';
import 'package:aapodcastguru/features/player/player_controls.dart';
import 'package:aapodcastguru/l10n/app_localizations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_player_engine.dart';

void main() {
  testWidgets('the play button keeps its size while the spinner runs', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final handler = PodcastAudioHandler(
      engine: FakePlayerEngine(),
      playback: PlaybackRepository(db, DateTime.now),
      settings: SettingsRepository(db),
    );
    addTearDown(() async {
      await handler.dispose();
      await db.close();
    });

    Future<Size> sizeWhile(AudioProcessingState processing) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioHandlerProvider.overrideWithValue(handler),
            playbackStateProvider.overrideWithValue(
              AsyncData(
                PlaybackState(playing: true, processingState: processing),
              ),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(child: PlayPauseButton(size: 48, filled: true)),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(IconButton));
    }

    final playing = await sizeWhile(AudioProcessingState.ready);
    final buffering = await sizeWhile(AudioProcessingState.buffering);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(buffering, playing);
  });
}
