import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatefulWidget {
  final StatefulNavigationShell shell;
  const HomeShell({super.key, required this.shell});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  bool _barVisible = true;

  void _setVisible(bool value) {
    if (_barVisible != value) setState(() => _barVisible = value);
  }

  bool _onScroll(UserScrollNotification notify) {
    if (notify.metrics.axis != Axis.vertical || notify.depth != 0) return false;
    switch (notify.direction) {
      case ScrollDirection.reverse:
        _setVisible(false);
      case ScrollDirection.forward:
        _setVisible(true);
      case ScrollDirection.idle:
        break;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: widget.shell,
      ),
      bottomNavigationBar: ClipRect(
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          heightFactor: _barVisible ? 1 : 0,
          child: NavigationBar(
            selectedIndex: widget.shell.currentIndex,
            onDestinationSelected: (idx) {
              _setVisible(true);
              widget.shell.goBranch(
                idx,
                initialLocation: idx == widget.shell.currentIndex,
              );
            },
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
        ),
      ),
    );
  }
}
