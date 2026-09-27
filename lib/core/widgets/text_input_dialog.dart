import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Asks for a short text (e.g. a playlist name). Returns null if cancelled
/// (or empty, unless [allowEmpty]).
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialValue = '',
  String? label,
  bool allowEmpty = false,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextInputDialog(
    title: title,
    confirmLabel: confirmLabel,
    initialValue: initialValue,
    label: label,
    allowEmpty: allowEmpty,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialValue,
    required this.label,
    required this.allowEmpty,
  });

  final String title;
  final String confirmLabel;
  final String initialValue;

  /// Field label; defaults to "Name".
  final String? label;

  /// Returns '' (instead of null) for an empty field, e.g. an optional note.
  final bool allowEmpty;

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
    Navigator.of(context).pop(text.isEmpty && !widget.allowEmpty ? null : text);
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
        decoration: InputDecoration(
          labelText: widget.label ?? l10n.playlistName,
        ),
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
