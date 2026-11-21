import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// Shows [child] only when the user's role is [minimum] or higher.
/// SUPER_ADMIN always sees it.
class RoleControl extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(sessionProvider).hasRole(minimum) ? child : fallback;
  }
}
