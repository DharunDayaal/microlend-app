import 'package:flutter/material.dart';

class LoanPaymentsScreen extends StatefulWidget {
  final String loanId;
  const new({super.key, required this.loanId});

  @override
  State<LoanPaymentsScreen> createState() => _LoanPaymentsScreenState();
}

class _LoanPaymentsScreenState extends State<LoanPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Loan payments screen")),
        ),
      ),
    );
  }
}
