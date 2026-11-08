import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_language.dart';
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';
import 'language_picker.dart';

/// After an update that brings the phone's language: asks once, in that
/// language, whether the app should switch to it (user wish 2026-11-08).
/// Invisible; checks once when the app shell first appears.
class NewLanguageOffer extends ConsumerStatefulWidget {
  const NewLanguageOffer({super.key});

  @override
  ConsumerState<NewLanguageOffer> createState() => _NewLanguageOfferState();
}

class _NewLanguageOfferState extends ConsumerState<NewLanguageOffer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (!mounted) return;
    // The phone's preferred language, as MaterialApp resolves it.
    final locales = View.of(context).platformDispatcher.locales;
    final device = locales.isEmpty ? null : locales.first;
    final settings = ref.read(settingsRepositoryProvider);
    final current = AppLanguage.fromSetting(
      await settings.get(SettingsKeys.language),
    );
    final offer = AppLanguage.newlyAvailable(
      current: current,
      device: device,
      known: await settings.get(SettingsKeys.knownLanguages),
    );
    if (offer == null || current == null || !mounted) return;

    // In the new language: the user may not read the current one well.
    final l10n = lookupAppLocalizations(offer.locale);
    final switchTo = await showDialog<bool>(
      context: context,
      builder: (context) => Localizations.override(
        context: context,
        locale: offer.locale,
        child: AlertDialog(
          title: Text(l10n.newLanguageTitle),
          content: Text(l10n.newLanguageBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.newLanguageKeep),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.newLanguageSwitch),
            ),
          ],
        ),
      ),
    );
    // Dismissed (back, tap outside) counts as "keep": ask only once.
    if (switchTo == true) {
      await setAppLanguage(ref, offer);
    } else {
      await rememberKnownLanguages(ref);
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
