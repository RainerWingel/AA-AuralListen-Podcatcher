import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'data/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();

  // Feeds are refreshed on app start only (no background refresh, see docs/decisions.md).
  unawaited(container.read(podcastRepositoryProvider).refreshAll());

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PodcastGuruApp(),
    ),
  );
}
