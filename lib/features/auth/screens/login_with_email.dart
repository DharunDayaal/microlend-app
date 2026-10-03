import 'package:flutter/material.dart';

class LoginWithEmailScreeen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginWithEmailScreeen> createState() => _LoginWithEmailScreeenState();
}

class _LoginWithEmailScreeenState extends State<LoginWithEmailScreeen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Login with email screen")),
        ),
      ),
    );
  }
}
