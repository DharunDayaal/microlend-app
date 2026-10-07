import 'package:flutter/material.dart';
class ApprovalPendingScreen extends StatelessWidget {
  const ApprovalPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Approval pending screen")),
        ),
      ),
    );
  }
}
