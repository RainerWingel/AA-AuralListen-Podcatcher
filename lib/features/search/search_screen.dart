import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/info_snack_bar.dart';
import '../../data/directory/directory_search.dart';
import '../../data/podcast_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Searches Apple Podcasts and fyyd; results can be subscribed with one tap.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

/// The lists below the search field (user wish 2026-10-21).
enum _Browse { top, latest }

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _debounce = Duration(milliseconds: 600);
  static const _minLength = 3;

  final _controller = TextEditingController();
  Timer? _debounceTimer;
  String _term = '';

  /// A list instead of a search: popular or new podcasts.
  _Browse? _browse;

  /// Feed URLs currently being subscribed (spinner) or just subscribed.
  final _busy = <String>{};
  final _justSubscribed = <String>{};

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounceTimer?.cancel();
    if (text.trim().length < _minLength) return;
    _debounceTimer = Timer(_debounce, () => _search(text));
  }

  void _search(String text) {
    _debounceTimer?.cancel();
    final term = text.trim();
    if (term.isEmpty || (term == _term && _browse == null)) return;
    setState(() {
      _term = term;
      _browse = null;
    });
  }

  void _show(_Browse list) {
    _debounceTimer?.cancel();
    FocusScope.of(context).unfocus();
    setState(() {
      _browse = list;
      _term = '';
      _controller.clear();
    });
  }

  Future<void> _subscribe(DirectoryResult result) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(result.feedUrl));
    try {
      final id = await ref
          .read(podcastRepositoryProvider)
          // Provisional until "Abonnieren" (user wish 2026-10-05).
          .subscribe(result.feedUrl, provisional: true);
      if (!mounted) return;
      setState(() => _justSubscribed.add(result.feedUrl));
      showInfoSnackBar(
        messenger,
        l10n.addedProvisionalSnack(result.title),
        action: SnackBarAction(
          label: l10n.open,
          onPressed: () => context.go(Routes.podcast(id)),
        ),
      );
    } on SubscribeException catch (e) {
      if (!mounted) return;
      showInfoSnackBar(messenger, switch (e.error) {
        SubscribeError.invalidUrl => l10n.subscribeErrorInvalidUrl,
        SubscribeError.alreadySubscribed =>
          l10n.subscribeErrorAlreadySubscribed,
        SubscribeError.network => l10n.subscribeErrorNetwork,
        SubscribeError.notAFeed => l10n.subscribeErrorNotAFeed,
      });
    } finally {
      if (mounted) setState(() => _busy.remove(result.feedUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.search),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: _term.isNotEmpty
          ? _Results(
              outcome: ref.watch(directorySearchResultsProvider(_term)),
              directories: 2,
              busy: _busy,
              justSubscribed: _justSubscribed,
              onSubscribe: _subscribe,
            )
          : switch (_browse) {
              null => EmptyState(
                icon: Icons.search,
                title: l10n.searchStart,
                hint: l10n.searchStartHint,
                // Popular and new podcasts, below the hint.
                action: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _show(_Browse.top),
                      icon: const Icon(Icons.trending_up),
                      label: Text(l10n.searchPopular),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _show(_Browse.latest),
                      icon: const Icon(Icons.fiber_new_outlined),
                      label: Text(l10n.searchNew),
                    ),
                  ],
                ),
              ),
              final list => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(l10n.searchPopular),
                          selected: list == _Browse.top,
                          onSelected: (_) => _show(_Browse.top),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l10n.searchNew),
                          selected: list == _Browse.latest,
                          onSelected: (_) => _show(_Browse.latest),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _Results(
                      outcome: ref.watch(switch (list) {
                        _Browse.top => directoryTopProvider,
                        _Browse.latest => directoryLatestProvider,
                      }),
                      directories: 1,
                      busy: _busy,
                      justSubscribed: _justSubscribed,
                      onSubscribe: _subscribe,
                    ),
                  ),
                ],
              ),
            },
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.outcome,
    required this.directories,
    required this.busy,
    required this.justSubscribed,
    required this.onSubscribe,
  });

  final AsyncValue<DirectorySearchOutcome> outcome;

  /// How many directories were asked (all failed = a connection problem).
  final int directories;
  final Set<String> busy;
  final Set<String> justSubscribed;
  final void Function(DirectoryResult) onSubscribe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subscribedKeys = ref.watch(subscribedFeedKeysProvider);

    return outcome.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          EmptyState(icon: Icons.cloud_off, title: l10n.searchFailed),
      data: (outcome) {
        final allFailed =
            outcome.results.isEmpty &&
            outcome.failedDirectories.length >= directories;
        if (allFailed) {
          return EmptyState(icon: Icons.cloud_off, title: l10n.searchFailed);
        }
        if (outcome.results.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: l10n.searchNoResults,
          );
        }
        return Column(
          children: [
            if (outcome.failedDirectories.isNotEmpty)
              MaterialBanner(
                content: Text(
                  l10n.searchPartialFailure(
                    outcome.failedDirectories.join(', '),
                  ),
                ),
                actions: const [SizedBox.shrink()],
              ),
            Expanded(
              child: ListView.builder(
                itemCount: outcome.results.length,
                itemBuilder: (context, index) {
                  final result = outcome.results[index];
                  final subscribed =
                      justSubscribed.contains(result.feedUrl) ||
                      subscribedKeys.contains(feedUrlKey(result.feedUrl));
                  return _ResultTile(
                    result: result,
                    subscribed: subscribed,
                    busy: busy.contains(result.feedUrl),
                    onSubscribe: () => onSubscribe(result),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.subscribed,
    required this.busy,
    required this.onSubscribe,
  });

  final DirectoryResult result;
  final bool subscribed;
  final bool busy;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meta = [
      ?result.author,
      if (result.episodeCount case final count?) l10n.episodeCount(count),
    ].join(' · ');

    return ListTile(
      leading: CoverImage(url: result.imageUrl, size: 56),
      title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: subscribed || busy ? null : onSubscribe,
      // Spinner and ✓ sit in a button-sized box, so all three line up with
      // the ⊕ of an IconButton (user report 2026-10-06: ✓ stood further right).
      trailing: busy
          ? const _TrailingBox(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : subscribed
          ? _TrailingBox(
              child: Tooltip(
                message: l10n.podcastInAbos,
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : IconButton(
              tooltip: l10n.podcastAdd,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onSubscribe,
            ),
    );
  }
}

/// Same size as an [IconButton] (48 × 48), content centred.
class _TrailingBox extends StatelessWidget {
  const _TrailingBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: kMinInteractiveDimension,
    child: Center(child: child),
  );
}
