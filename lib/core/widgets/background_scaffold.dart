import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A screen with a decorative [background] behind everything, including the
/// (transparent) title bar. The [body] stays below the title bar, so list
/// content never scrolls underneath the title.
class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold({
    required this.background,
    required this.title,
    required this.body,
    this.actions,
    super.key,
  });

  final Widget background;
  final Widget title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Stack(
      children: [
        Positioned.fill(child: background),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            // A transparent bar counts as "dark" for Flutter, which would make
            // the status bar icons white in light mode (bug 2026-09-30). Only
            // the status bar is set; the navigation bar stays as it is.
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: light
                  ? Brightness.dark
                  : Brightness.light,
              statusBarBrightness: light ? Brightness.light : Brightness.dark,
            ),
            title: title,
            actions: actions,
          ),
          body: body,
        ),
      ],
    );
  }
}
