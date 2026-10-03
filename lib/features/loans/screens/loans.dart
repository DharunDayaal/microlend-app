import 'package:flutter/material.dart';

class LoansScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Loans screen")),
        ),
      ),
    );
  }
}
