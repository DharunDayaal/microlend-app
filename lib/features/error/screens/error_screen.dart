import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Text(
              context.l10n.errorPageNotFound,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
