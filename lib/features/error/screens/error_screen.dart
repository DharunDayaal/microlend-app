import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("404! Page not found.")),
        ),
      ),
    );
  }
}
