import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Asks for a short text (e.g. a playlist name). Returns null if cancelled
/// or empty.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialValue = '',
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextInputDialog(
    title: title,
    confirmLabel: confirmLabel,
    initialValue: initialValue,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialValue,
  });

  final String title;
  final String confirmLabel;
  final String initialValue;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    Navigator.of(context).pop(text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l10n.playlistName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
