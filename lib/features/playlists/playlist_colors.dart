import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Full-strength rainbow colors (picker circles).
Color playlistColorValue(PlaylistColor color) => switch (color) {
  PlaylistColor.red => const Color(0xFFE53935),
  PlaylistColor.orange => const Color(0xFFFB8C00),
  PlaylistColor.yellow => const Color(0xFFFDD835),
  PlaylistColor.green => const Color(0xFF43A047),
  PlaylistColor.blue => const Color(0xFF1E88E5),
  PlaylistColor.indigo => const Color(0xFF3949AB),
  PlaylistColor.violet => const Color(0xFF8E24AA),
};

/// Soft background for a colored playlist: the color blended into the
/// surface, so the normal text stays readable in light and dark mode.
/// Null = no color (default background).
Color? playlistBackground(BuildContext context, PlaylistColor? color) {
  if (color == null) return null;
  final theme = Theme.of(context);
  final dark = theme.brightness == Brightness.dark;
  return Color.alphaBlend(
    playlistColorValue(color).withValues(alpha: dark ? 0.30 : 0.22),
    theme.colorScheme.surface,
  );
}

String playlistColorName(AppLocalizations l10n, PlaylistColor color) =>
    switch (color) {
      PlaylistColor.red => l10n.colorRed,
      PlaylistColor.orange => l10n.colorOrange,
      PlaylistColor.yellow => l10n.colorYellow,
      PlaylistColor.green => l10n.colorGreen,
      PlaylistColor.blue => l10n.colorBlue,
      PlaylistColor.indigo => l10n.colorIndigo,
      PlaylistColor.violet => l10n.colorViolet,
    };

/// "Farbe…": pick one of the rainbow colors or none.
Future<void> choosePlaylistColor(
  BuildContext context,
  WidgetRef ref,
  Playlist playlist,
) async {
  final l10n = AppLocalizations.of(context);
  // Record wrapper: "no color" must be distinguishable from "cancelled".
  final chosen = await showDialog<({PlaylistColor? color})>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      Widget circle({required PlaylistColor? color, required String label}) {
        final selected = playlist.color == color;
        final fill = color == null ? scheme.surface : playlistColorValue(color);
        return Tooltip(
          message: label,
          child: Semantics(
            label: label,
            selected: selected,
            button: true,
            child: InkResponse(
              onTap: () => Navigator.of(context).pop((color: color)),
              radius: 28,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? scheme.onSurface : scheme.outline,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: color == null
                    ? Icon(Icons.format_color_reset, color: scheme.outline)
                    : selected
                    ? Icon(
                        Icons.check,
                        color:
                            ThemeData.estimateBrightnessForColor(fill) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      )
                    : null,
              ),
            ),
          ),
        );
      }

      return AlertDialog(
        title: Text(l10n.playlistColor),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final color in PlaylistColor.values)
              circle(color: color, label: playlistColorName(l10n, color)),
            circle(color: null, label: l10n.playlistColorNone),
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
  if (chosen == null || chosen.color == playlist.color) return;
  await ref
      .read(playlistRepositoryProvider)
      .setColor(playlist.id, chosen.color);
}
