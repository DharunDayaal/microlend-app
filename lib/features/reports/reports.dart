import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Reports screen")),
        ),
      ),
    );
  }
}
