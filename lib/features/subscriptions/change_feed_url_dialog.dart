import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/podcast_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Lets the user point a subscription to a new feed address (the podcast
/// moved without redirect). Returns true if the address was changed.
Future<bool> showChangeFeedUrlDialog(BuildContext context, Podcast podcast) =>
    showDialog<bool>(
      context: context,
      builder: (_) => _ChangeFeedUrlDialog(podcast: podcast),
    ).then((changed) => changed ?? false);

class _ChangeFeedUrlDialog extends ConsumerStatefulWidget {
  const _ChangeFeedUrlDialog({required this.podcast});

  final Podcast podcast;

  @override
  ConsumerState<_ChangeFeedUrlDialog> createState() =>
      _ChangeFeedUrlDialogState();
}

class _ChangeFeedUrlDialogState extends ConsumerState<_ChangeFeedUrlDialog> {
  late final _controller = TextEditingController(text: widget.podcast.feedUrl);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    if (_controller.text.trim() == widget.podcast.feedUrl) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(podcastRepositoryProvider)
          .changeFeedUrl(widget.podcast.id, _controller.text);
      if (mounted) Navigator.of(context).pop(true);
    } on SubscribeException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (e.error) {
          SubscribeError.invalidUrl => l10n.subscribeErrorInvalidUrl,
          SubscribeError.alreadySubscribed => l10n.feedUrlTaken,
          SubscribeError.network => l10n.subscribeErrorNetwork,
          SubscribeError.notAFeed => l10n.subscribeErrorNotAFeed,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.feedUrlChange),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.feedUrlChangeHint),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_busy,
            keyboardType: TextInputType.url,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l10n.feedUrl,
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.feedUrlChangeSubmit),
        ),
      ],
    );
  }
}
