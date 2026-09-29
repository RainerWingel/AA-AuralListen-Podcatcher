import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_info.dart';
import '../../core/app_platform.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../l10n/app_localizations.dart';

/// Optionen → Info: name, installed version, developer, tip and links.
class InfoScreen extends ConsumerWidget {
  const InfoScreen({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (!await ref.read(appPlatformProvider).openUrl(url)) {
      showInfoSnackBar(messenger, l10n.infoLinkFailed);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Straight from Android (set by the build from pubspec.yaml); the
    // constant is only a fallback outside Android.
    final installed = ref.watch(installedVersionProvider).value;
    final version = installed == null
        ? l10n.infoVersionShort(appVersion)
        : l10n.infoVersion(installed.name, installed.build);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.infoTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/app_icon.webp',
                width: 112,
                height: 112,
                cacheWidth: 336,
                semanticLabel: appName,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(version, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            l10n.infoDeveloper(appDeveloper),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (showTipLink)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.infoTipText),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () => _open(context, ref, tipUrl),
                        icon: const Icon(Icons.favorite_outline),
                        label: Text(l10n.infoTipButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.infoPrivacy),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open(context, ref, privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.infoSourceCode),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open(context, ref, sourceCodeUrl),
          ),
        ],
      ),
    );
  }
}
