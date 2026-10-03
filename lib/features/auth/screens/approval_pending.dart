import 'package:flutter/material.dart';

class ApprovalPendingScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ApprovalPendingScreen> createState() => _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends State<ApprovalPendingScreen> {
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
