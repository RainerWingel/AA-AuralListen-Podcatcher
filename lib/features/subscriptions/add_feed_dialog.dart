import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/podcast_repository.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Asks for a feed URL and subscribes. Returns the podcast id on success
/// (or the id of the existing subscription), null if cancelled.
Future<int?> showAddFeedDialog(BuildContext context) =>
    showDialog<int>(context: context, builder: (_) => const _AddFeedDialog());

class _AddFeedDialog extends ConsumerStatefulWidget {
  const _AddFeedDialog();

  @override
  ConsumerState<_AddFeedDialog> createState() => _AddFeedDialogState();
}

class _AddFeedDialogState extends ConsumerState<_AddFeedDialog> {
  final _controller = TextEditingController();
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
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(podcastRepositoryProvider)
          .subscribe(_controller.text);
      if (mounted) Navigator.of(context).pop(id);
    } on SubscribeException catch (e) {
      if (!mounted) return;
      if (e.error == SubscribeError.alreadySubscribed) {
        // Nothing to do – just open the existing podcast.
        Navigator.of(context).pop(e.existingPodcastId);
        return;
      }
      setState(() {
        _busy = false;
        _error = switch (e.error) {
          SubscribeError.invalidUrl => l10n.subscribeErrorInvalidUrl,
          SubscribeError.alreadySubscribed =>
            l10n.subscribeErrorAlreadySubscribed,
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
      title: Text(l10n.addFeedTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        enabled: !_busy,
        keyboardType: TextInputType.url,
        autocorrect: false,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: l10n.addFeedLabel,
          hintText: l10n.addFeedHint,
          errorText: _error,
          errorMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.addFeedSubmit),
        ),
      ],
    );
  }
}
