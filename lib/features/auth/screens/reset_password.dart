import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(child: Text("Login with phone screen")),
        ),
      ),
    );
  }
}