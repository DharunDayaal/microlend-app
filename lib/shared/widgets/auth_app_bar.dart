import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/constants/assets.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AuthAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      leadingWidth: 300,
      toolbarHeight: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              Assets.logo,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.appName,
                    textAlign: TextAlign.start,
                    style: textTheme.labelLarge,
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
