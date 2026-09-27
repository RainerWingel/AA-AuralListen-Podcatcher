import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Temporary screen body for tabs that are not implemented yet.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(AppLocalizations.of(context).placeholderComingSoon),
      ),
    );
  }
}
