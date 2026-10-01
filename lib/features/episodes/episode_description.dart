import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_platform.dart';
import '../../core/text_utils.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Show notes of an episode in a bottom sheet (long press menu).
Future<void> showEpisodeDescriptionSheet(
  BuildContext context, {
  required int episodeId,
  required String title,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  // Above the mini player and navigation bar, below the status bar.
  useRootNavigator: true,
  useSafeArea: true,
  builder: (context) => ConstrainedBox(
    // Long show notes scroll inside the sheet instead of covering the screen.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
    ),
    child: ListView(
      shrinkWrap: true,
      // The end of the text stays above Android's navigation buttons.
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, _) {
            final notes = ref.watch(episodeNotesProvider(episodeId));
            return switch (notes) {
              AsyncData(value: final text?) when text.isNotEmpty => NotesText(
                text,
              ),
              AsyncData() || AsyncError() => Text(
                AppLocalizations.of(context).episodeNoDescription,
              ),
              _ => const LinearProgressIndicator(),
            };
          },
        ),
      ],
    ),
  ),
);

/// Collapsible "Description" section at the bottom of the full-screen player.
/// Hidden when the episode has no show notes.
class EpisodeDescriptionSection extends ConsumerWidget {
  const EpisodeDescriptionSection({required this.episodeId, super.key});

  final int episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(episodeNotesProvider(episodeId)).value;
    if (notes == null || notes.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      // A new episode starts collapsed again.
      key: ValueKey(episodeId),
      title: Text(AppLocalizations.of(context).episodeDescription),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      expandedAlignment: Alignment.topLeft,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [NotesText(notes)],
    );
  }
}

/// Stored show notes with tappable links (opened in the browser) and
/// selectable text.
class NotesText extends ConsumerStatefulWidget {
  const NotesText(this.notes, {super.key});

  final String notes;

  @override
  ConsumerState<NotesText> createState() => _NotesTextState();
}

class _NotesTextState extends ConsumerState<NotesText> {
  // One recognizer per link; they hold gesture state and must be disposed
  // (docs/eviction.md), so they live here and not in build().
  List<NotesPart> _parts = const [];
  List<TapGestureRecognizer?> _recognizers = const [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  @override
  void didUpdateWidget(NotesText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes) {
      _disposeRecognizers();
      _build();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _build() {
    _parts = parseNotes(widget.notes);
    _recognizers = [
      for (final part in _parts)
        if (part.url case final url?)
          (TapGestureRecognizer()..onTap = () => _open(url))
        else
          null,
    ];
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r?.dispose();
    }
  }

  Future<void> _open(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (!await ref.read(appPlatformProvider).openUrl(url)) {
      showInfoSnackBar(messenger, l10n.infoLinkFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
    );
    return SelectionArea(
      child: Text.rich(
        TextSpan(
          children: [
            for (var i = 0; i < _parts.length; i++)
              TextSpan(
                text: _parts[i].text,
                style: _parts[i].url == null ? null : linkStyle,
                recognizer: _recognizers[i],
              ),
          ],
        ),
      ),
    );
  }
}
