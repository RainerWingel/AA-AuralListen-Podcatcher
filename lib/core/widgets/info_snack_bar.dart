import 'package:flutter/material.dart';

/// How long an info message stays visible (user rule: at most 7 seconds).
const infoDuration = Duration(seconds: 4);

/// Messages with a button (e.g. "Rückgängig") get a little longer.
const infoWithActionDuration = Duration(seconds: 6);

/// The only way this app shows a SnackBar (docs/ui-ux.md):
/// - replaces the current message instead of queueing behind it, and
/// - always disappears on its own. Flutter keeps SnackBars with an action
///   until dismissed unless `persist: false` is set.
void showInfoSnackBar(
  ScaffoldMessengerState messenger,
  String text, {
  SnackBarAction? action,
}) {
  messenger
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        action: action,
        persist: false,
        duration: action == null ? infoDuration : infoWithActionDuration,
      ),
    );
}
