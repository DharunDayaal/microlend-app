import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';

/// Temporary screen body. Replace each use as the real screen is built.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          context.l10n.placeholderComingSoon(title),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
