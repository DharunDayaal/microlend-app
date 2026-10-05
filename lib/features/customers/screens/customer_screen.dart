import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';

class CustomerScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: [
                Text("customer screen"),
                AppButton(
                  label: "Logout",
                  onPressed: () async {
                    await AuthService.logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
