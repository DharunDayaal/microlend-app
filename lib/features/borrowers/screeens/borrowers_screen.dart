import 'package:flutter/material.dart';

class BorrowerScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<BorrowerScreen> createState() => _BorrowerScreenState();
}

class _BorrowerScreenState extends State<BorrowerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("borrowers screen")),
        ),
      ),
    );
  }
}
