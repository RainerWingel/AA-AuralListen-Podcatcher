import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

/// Collapsible "Description" section at the bottom of the full-screen player:
/// episode number (as on the cover) and publication date on top (user wish
/// 2026-10-04), then the show notes. Hidden when there is none of them.
class EpisodeDescriptionSection extends ConsumerWidget {
  const EpisodeDescriptionSection({
    required this.episodeId,
    this.podcastId,
    this.pubDate,
    super.key,
  });

  final int episodeId;
  final int? podcastId;
  final DateTime? pubDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notes = ref.watch(episodeNotesProvider(episodeId)).value;
    final number = switch (podcastId) {
      final id? => ref.watch(
        episodeNumbersProvider(id).select((n) => n.value?[episodeId]),
      ),
      null => null,
    };
    final facts = [
      if (number != null) l10n.episodeNumberLabel(number),
      if (pubDate case final date?)
        DateFormat.yMMMMd(l10n.localeName).format(date.toLocal()),
    ].join(' · ');
    final hasNotes = notes != null && notes.isNotEmpty;
    if (!hasNotes && facts.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return ExpansionTile(
      // A new episode starts collapsed again.
      key: ValueKey(episodeId),
      title: Text(AppLocalizations.of(context).episodeDescription),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      expandedAlignment: Alignment.topLeft,
      // Number/date line left-aligned like the notes below it.
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [
        if (facts.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: hasNotes ? 12 : 0),
            child: Text(
              facts,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (hasNotes) NotesText(notes),
      ],
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
