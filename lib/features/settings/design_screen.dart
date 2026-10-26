import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/panel_design.dart';
import '../../data/providers.dart';
import '../../data/settings_keys.dart';
import '../../l10n/app_localizations.dart';
import '../player/panel_background.dart';
import 'app_color_picker.dart';
import 'settings_screen.dart';

String panelDesignName(AppLocalizations l10n, PanelDesign design) =>
    switch (design) {
      PanelDesign.plain => l10n.panelDesignPlain,
      PanelDesign.stars => l10n.panelDesignStars,
      PanelDesign.aurora => l10n.panelDesignAurora,
      PanelDesign.waves => l10n.panelDesignWaves,
      PanelDesign.facets => l10n.panelDesignFacets,
    };

/// Optionen → Design: light/dark mode, app color and the background of the
/// player's control panel (user wish 2026-10-26; the first two used to be
/// directly in Optionen).
class DesignScreen extends ConsumerWidget {
  const DesignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected =
        ref.watch(panelDesignProvider).value ?? PanelDesign.standard;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.designTitle)),
      body: ListView(
        children: [
          SettingsSectionHeader(l10n.settingsSectionAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.themeSystem),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {
                ref.watch(themeModeProvider).value ?? ThemeMode.system,
              },
              onSelectionChanged: (v) => ref
                  .read(settingsRepositoryProvider)
                  .set(SettingsKeys.themeMode, v.single.name),
            ),
          ),
          const AppColorTile(),
          SettingsSectionHeader(l10n.designSectionPanel),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              l10n.designPanelHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final design in PanelDesign.values)
                  _DesignChoice(
                    design: design,
                    selected: design == selected,
                    onTap: () => ref
                        .read(settingsRepositoryProvider)
                        .set(SettingsKeys.panelDesign, design.name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One selectable design: a small preview of the panel with mock controls,
/// painted with the current colors (so it shows what dark mode and the app
/// color do to it), and its name below.
class _DesignChoice extends StatelessWidget {
  const _DesignChoice({
    required this.design,
    required this.selected,
    required this.onTap,
  });

  final PanelDesign design;
  final bool selected;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final name = panelDesignName(l10n, design);
    // Two per row on a phone; fixed width keeps the Wrap tidy.
    final width = (MediaQuery.sizeOf(context).width - 32 - 12) / 2;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('panel-design-${design.name}'),
        borderRadius: _radius,
        onTap: onTap,
        child: SizedBox(
          width: width.clamp(120, 260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: _radius,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: PanelBackground(
                  design: design,
                  borderRadius: _radius,
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: _MockControls(selected: selected),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (selected) ...[
                    Icon(Icons.check_circle, size: 18, color: scheme.primary),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A seek bar and the three play buttons, drawn small on top of the design.
class _MockControls extends StatelessWidget {
  const _MockControls({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.4,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.replay, size: 20, color: scheme.onSurface),
              CircleAvatar(
                radius: 15,
                backgroundColor: scheme.primary,
                child: Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: scheme.onPrimary,
                ),
              ),
              Icon(Icons.forward_30, size: 20, color: scheme.onSurface),
            ],
          ),
        ],
      ),
    );
  }
}
