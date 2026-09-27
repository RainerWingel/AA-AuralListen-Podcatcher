import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/widgets/cover_image.dart';
import '../../core/widgets/empty_state.dart';
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

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _debounce = Duration(milliseconds: 600);
  static const _minLength = 3;

  final _controller = TextEditingController();
  Timer? _debounceTimer;
  String _term = '';

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
    if (term.isEmpty || term == _term) return;
    setState(() => _term = term);
  }

  Future<void> _subscribe(DirectoryResult result) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(result.feedUrl));
    try {
      final id = await ref
          .read(podcastRepositoryProvider)
          .subscribe(result.feedUrl);
      if (!mounted) return;
      setState(() => _justSubscribed.add(result.feedUrl));
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.subscribedSnack(result.title)),
          action: SnackBarAction(
            label: l10n.open,
            onPressed: () => context.go(Routes.podcast(id)),
          ),
        ),
      );
    } on SubscribeException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (e.error) {
            SubscribeError.invalidUrl => l10n.subscribeErrorInvalidUrl,
            SubscribeError.alreadySubscribed =>
              l10n.subscribeErrorAlreadySubscribed,
            SubscribeError.network => l10n.subscribeErrorNetwork,
            SubscribeError.notAFeed => l10n.subscribeErrorNotAFeed,
          }),
        ),
      );
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
      body: _term.isEmpty
          ? EmptyState(
              icon: Icons.search,
              title: l10n.searchStart,
              hint: l10n.searchStartHint,
            )
          : _Results(
              term: _term,
              busy: _busy,
              justSubscribed: _justSubscribed,
              onSubscribe: _subscribe,
            ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.term,
    required this.busy,
    required this.justSubscribed,
    required this.onSubscribe,
  });

  final String term;
  final Set<String> busy;
  final Set<String> justSubscribed;
  final void Function(DirectoryResult) onSubscribe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final outcome = ref.watch(directorySearchResultsProvider(term));
    final subscribedKeys = ref.watch(subscribedFeedKeysProvider);

    return outcome.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          EmptyState(icon: Icons.cloud_off, title: l10n.searchFailed),
      data: (outcome) {
        final allFailed =
            outcome.results.isEmpty && outcome.failedDirectories.length > 1;
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
      trailing: busy
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : subscribed
          ? Tooltip(
              message: l10n.subscribed,
              child: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : IconButton(
              tooltip: l10n.subscribeAction,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onSubscribe,
            ),
    );
  }
}
