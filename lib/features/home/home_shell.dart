import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/features/home/widgets/profile_menu_sheet.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/assets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class _Tab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final UserRole minimum;

  const _Tab(
    this.label,
    this.icon,
    this.selectedIcon, {
    this.minimum = UserRole.user,
  });
}

class HomeShell extends StatefulWidget {
  final StatefulNavigationShell shell;
  const HomeShell({super.key, required this.shell});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _tabs = [
    _Tab('Field', Icons.fact_check_outlined, Icons.fact_check),
    _Tab('Loans', Icons.account_balance_outlined, Icons.account_balance),
    _Tab('Borrowers', Icons.people_outline, Icons.people),
    _Tab('Reports', Icons.bar_chart_outlined, Icons.bar_chart),
  ];

  bool _barVisible = true;

  void _setBarVisible(bool v) {
    if (_barVisible != v) setState(() => _barVisible = v);
  }

  bool _onScroll(UserScrollNotification n) {
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;

    switch (n.direction) {
      case ScrollDirection.reverse:
        _setBarVisible(false);
      case ScrollDirection.forward:
        _setBarVisible(true);
      case ScrollDirection.idle:
        break;
    }
    return false;
  }

  void _openMenu() {
    ProfileMenuSheet.show(
      context,
      onLogout: () => AuthService.logout(),
      items: [
        ProfileMenuItem(
          icon: Icons.person_outline,
          title: 'My profile',
          subtitle: 'Name, phone, email and loan defaults',
          onTap: () {
            context.push(AppRoutes.profile);
          },
        ),
        ProfileMenuItem(
          icon: Icons.person_add_alt_1_outlined,
          title: 'Add borrower',
          subtitle: 'Register a new customer',
          onTap: () {
            context.push(AppRoutes.addCustomer);
          },
        ),
        ProfileMenuItem(
          icon: Icons.manage_accounts_outlined,
          title: 'Manage users',
          subtitle: 'Add team members and set roles',
          minimum: UserRole.admin,
          onTap: () {
            // TODO: context.push(AppRoutes.manageUsers)
          },
        ),
        ProfileMenuItem(
          icon: Icons.insights_outlined,
          title: 'Advanced analytics',
          subtitle: 'Recovery, overdue trends and collections',
          minimum: UserRole.admin,
          onTap: () {
            context.push(AppRoutes.analytics);
          },
        ),
        ProfileMenuItem(
          icon: Icons.admin_panel_settings_outlined,
          title: 'All admins',
          subtitle: 'Approve and manage admin accounts',
          minimum: UserRole.superAdmin,
          onTap: () {
            // TODO: context.push(AppRoutes.admins);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the logged-in user or role changes.
    return ListenableBuilder(
      listenable: CurrentUser.instance,
      builder: (context, _) {
        final me = CurrentUser.instance;

        if (!me.isSignedIn) return const Scaffold();

        final index = widget.shell.currentIndex;
        final tab = _tabs[index.clamp(0, _tabs.length - 1)];

        if (!me.hasRole(tab.minimum)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.shell.goBranch(0);
          });
        }

        final visible = <int>[
          for (var i = 0; i < _tabs.length; i++)
            if (me.hasRole(_tabs[i].minimum)) i,
        ];
        final selected = visible.indexOf(index);

        return Scaffold(
          appBar: _ShellAppBar(title: tab.label, onProfileTap: _openMenu),
          body: NotificationListener<UserScrollNotification>(
            onNotification: _onScroll,
            child: widget.shell,
          ),
          bottomNavigationBar: visible.length < 2
              ? null
              : ClipRect(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    heightFactor: _barVisible ? 1 : 0,
                    child: NavigationBar(
                      selectedIndex: selected < 0 ? 0 : selected,
                      onDestinationSelected: (i) {
                        _setBarVisible(true);
                        final branch = visible[i];
                        widget.shell.goBranch(
                          branch,
                          initialLocation: branch == widget.shell.currentIndex,
                        );
                      },
                      destinations: [
                        for (final i in visible)
                          NavigationDestination(
                            label: _tabs[i].label,
                            icon: Icon(_tabs[i].icon),
                            selectedIcon: Icon(_tabs[i].selectedIcon),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onProfileTap;

  const _ShellAppBar({required this.title, required this.onProfileTap});

  static const double _height = 72;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final user = CurrentUser.instance.user;

    final firstName = (user?.userName ?? '').trim().split(RegExp(r'\s+')).first;
    final eyebrow =
        (firstName.isEmpty ? 'MICROLEND FIELD' : '${_greeting()}, $firstName')
            .toUpperCase();

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: _height,
      titleSpacing: AppSizes.lg,
      backgroundColor: AppColors.darkBackground,
      surfaceTintColor: Colors.transparent,
      // the gradient and hairline sit behind the status bar too
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkAppBar, AppColors.darkBackground],
            stops: [0, 0.75],
          ),
          border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
        ),
      ),
      title: Row(
        children: [
          // brand tile
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd + 2),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Image.asset(Assets.logo, fit: BoxFit.contain),
          ),
          const SizedBox(width: AppSizes.md),
          // greeting + title, animated when the tab changes
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey(title),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: text.labelSmall?.copyWith(
                      color: AppColors.stepCurrentLabel,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: text.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        _RingAvatar(
          name: user?.userName ?? '',
          role: CurrentUser.instance.role,
          onTap: onProfileTap,
        ),
        const SizedBox(width: AppSizes.sm),
      ],
    );
  }
}

/// Initials inside a gradient ring. The ring colour shows the role.
class _RingAvatar extends StatelessWidget {
  final String name;
  final UserRole role;
  final VoidCallback onTap;

  const _RingAvatar({
    required this.name,
    required this.role,
    required this.onTap,
  });

  List<Color> get _ring => switch (role) {
    UserRole.superAdmin => const [AppColors.warning, AppColors.progressWarning],
    UserRole.admin => const [AppColors.stepCurrentLabel, AppColors.darkPrimary],
    UserRole.user => const [AppColors.darkRim, AppColors.darkBorder],
  };

  @override
  Widget build(BuildContext context) {
    final outer = BorderRadius.circular(16);

    return Semantics(
      button: true,
      label: 'Open profile menu',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: outer),
          child: Padding(
            padding: const EdgeInsets.all(3), // 48px tap target
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _ring,
                ),
                borderRadius: outer,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: AppNameCard(name: name, width: 34, height: 34),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
