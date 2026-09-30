import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_color.dart';
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';

String appColorName(AppLocalizations l10n, AppColor color) => switch (color) {
  AppColor.orange => l10n.colorOrange,
  AppColor.red => l10n.colorRed,
  AppColor.pink => l10n.colorPink,
  AppColor.purple => l10n.colorPurple,
  AppColor.blue => l10n.colorBlue,
  AppColor.teal => l10n.colorTeal,
  AppColor.green => l10n.colorGreen,
  AppColor.brown => l10n.colorBrown,
  AppColor.wallpaper => l10n.appColorWallpaper,
};

/// Optionen → Darstellung → "App-Farbe": the whole app, including the
/// backgrounds of Home and Downloads, switches immediately.
class AppColorTile extends ConsumerWidget {
  const AppColorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(effectiveAppColorProvider);
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l10n.appColor),
      subtitle: Text(appColorName(l10n, current)),
      trailing: _Dot(color: ref.watch(seedColorProvider), size: 24),
      onTap: () => _choose(context, ref, current),
    );
  }

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    AppColor current,
  ) async {
    final l10n = AppLocalizations.of(context);
    // Offered only where the phone has wallpaper colors (Android 12+).
    final wallpaper = ref.read(wallpaperColorProvider);
    final chosen = await showDialog<AppColor>(
      context: context,
      builder: (context) {
        Widget option(AppColor color, Color fill) {
          final selected = color == current;
          return Tooltip(
            message: appColorName(l10n, color),
            child: Semantics(
              label: appColorName(l10n, color),
              selected: selected,
              button: true,
              child: InkResponse(
                onTap: () => Navigator.of(context).pop(color),
                radius: 28,
                child: _Dot(
                  color: fill,
                  size: 44,
                  selected: selected,
                  icon: color == AppColor.wallpaper ? Icons.wallpaper : null,
                ),
              ),
            ),
          );
        }

        return AlertDialog(
          title: Text(l10n.appColor),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final color in AppColor.values)
                if (color.seed case final seed?) option(color, seed),
              if (wallpaper != null) option(AppColor.wallpaper, wallpaper),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
    if (chosen == null || chosen == current) return;
    await ref
        .read(settingsRepositoryProvider)
        .set(SettingsKeys.appColor, chosen.name);
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.color,
    required this.size,
    this.selected = false,
    this.icon,
  });

  final Color color;
  final double size;
  final bool selected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.onSurface : scheme.outline,
          width: selected ? 3 : 1,
        ),
      ),
      child: selected
          ? Icon(Icons.check, color: onColor)
          : icon == null
          ? null
          : Icon(icon, color: onColor, size: size / 2),
    );
  }
}
