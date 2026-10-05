import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Asks for a short text (e.g. a playlist name). Returns null if cancelled
/// (or empty, unless [allowEmpty]). [validate] returns an error message for
/// the trimmed text (shown under the field, the dialog stays open) or null.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialValue = '',
  String? label,
  bool allowEmpty = false,
  String? Function(String text)? validate,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextInputDialog(
    title: title,
    confirmLabel: confirmLabel,
    initialValue: initialValue,
    label: label,
    allowEmpty: allowEmpty,
    validate: validate,
  ),
);

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialValue,
    required this.label,
    required this.allowEmpty,
    required this.validate,
  });

  final String title;
  final String confirmLabel;
  final String initialValue;

  /// Field label; defaults to "Name".
  final String? label;

  /// Returns '' (instead of null) for an empty field, e.g. an optional note.
  final bool allowEmpty;

  final String? Function(String text)? validate;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty && !widget.allowEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final error = widget.validate?.call(text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(text);
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
          errorText: _error,
        ),
        // The message goes away as soon as the text is changed.
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
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
