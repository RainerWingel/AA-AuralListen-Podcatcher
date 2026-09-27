import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_screen.dart';
import '../../l10n/app_localizations.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: AppLocalizations.of(context).navPlaylists);
}
