import 'package:flutter/material.dart';

class LoginWithPhoneScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginWithPhoneScreen> createState() => _LoginWithPhoneScreenState();
}

class _LoginWithPhoneScreenState extends State<LoginWithPhoneScreen> {
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
