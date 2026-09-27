import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: AppLocalizations.of(context).navHome);
}
