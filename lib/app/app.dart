import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_language.dart';
import '../data/providers.dart';
import '../features/settings/language_picker.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

/// Root widget: wires up routing, theme and localization. Until a language is
/// chosen (first start) it shows the language picker instead of the app.
class AuralListenApp extends ConsumerWidget {
  const AuralListenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final seed = ref.watch(seedColorProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(seed),
      darkTheme: AppTheme.dark(seed),
      themeMode: ref.watch(themeModeProvider).value ?? ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      // null = not chosen yet: the picker is shown in the device's language.
      locale: language.value?.locale,
      localeResolutionCallback: (deviceLocale, _) =>
          AppLanguage.forDevice(deviceLocale).locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Settings still loading (a few milliseconds): blank, no flicker.
        if (language.isLoading && !language.hasValue) {
          return ColoredBox(color: Theme.of(context).colorScheme.surface);
        }
        if (!language.hasError && language.value == null) {
          return const LanguagePickerScreen();
        }
        return child!;
      },
    );
  }
}
