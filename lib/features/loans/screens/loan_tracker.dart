import 'package:flutter/material.dart';

class LoanTrackerScreen extends StatefulWidget {
  final String loanId;
  const new({super.key, required this.loanId});

  @override
  State<LoanTrackerScreen> createState() => _LoanTrackerScreenState();
}

class _LoanTrackerScreenState extends State<LoanTrackerScreen> {
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
