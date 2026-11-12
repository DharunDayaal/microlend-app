import 'package:flutter/material.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

/// Shows [child] only when the user's role is [minimum] or higher.
/// SUPER_ADMIN always sees it.
class RoleControl extends StatelessWidget {
  final UserRole minimum;
  final Widget child;
  final Widget fallback;
  const new({
    super.key,
    required this.minimum,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrentUser.instance,
      builder: (_, _) =>
          CurrentUser.instance.hasRole(minimum) ? child : fallback,
    );
  }
}
