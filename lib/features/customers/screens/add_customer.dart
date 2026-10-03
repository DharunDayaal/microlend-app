import 'package:flutter/material.dart';

class AddCustomerScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Add customer screen")),
        ),
      ),
    );
  }
}
