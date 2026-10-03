import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const HomeShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (value) =>
            shell.goBranch(value, initialLocation: value == shell.currentIndex),
        destinations: [
          NavigationDestination(
            label: "Field",
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
          ),
          NavigationDestination(
            label: "Loans",
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
          ),
          NavigationDestination(
            label: "Borrowers",
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
          ),
          NavigationDestination(
            label: "Reports",
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
          ),
        ],
      ),
    );
  }
}
