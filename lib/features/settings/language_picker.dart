import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_language.dart';
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';

/// Stores the chosen UI language; the whole app switches immediately.
Future<void> setAppLanguage(WidgetRef ref, AppLanguage language) => ref
    .read(settingsRepositoryProvider)
    .set(SettingsKeys.language, language.name);

/// Name of a language in that language ("Deutsch", "English").
String languageName(AppLocalizations l10n, AppLanguage language) =>
    switch (language) {
      AppLanguage.de => l10n.languageGerman,
      AppLanguage.en => l10n.languageEnglish,
    };

/// First start: asks for the UI language before the app is shown.
class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/app_icon.webp',
                    width: 96,
                    height: 96,
                    cacheWidth: 288,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.languagePickerTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.languagePickerHint,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                for (final language in AppLanguage.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () => setAppLanguage(ref, language),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(languageName(l10n, language)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Optionen: dialog to change the UI language.
Future<void> chooseAppLanguage(
  BuildContext context,
  WidgetRef ref,
  AppLanguage current,
) async {
  final l10n = AppLocalizations.of(context);
  final chosen = await showDialog<AppLanguage>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.language),
      children: [
        RadioGroup<AppLanguage>(
          groupValue: current,
          onChanged: (v) => Navigator.of(context).pop(v),
          child: Column(
            children: [
              for (final language in AppLanguage.values)
                RadioListTile<AppLanguage>(
                  value: language,
                  title: Text(languageName(l10n, language)),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  if (chosen != null && chosen != current) await setAppLanguage(ref, chosen);
}
