import 'package:flutter/material.dart';

class IssueLoanScreen extends StatelessWidget {
  final String stepNo;
  const IssueLoanScreen({super.key, required this.stepNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Login with phone screen")),
        ),
      ),
    );
  }
}
