import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/assets.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Microlend Field",
                  textAlign: TextAlign.start,
                  style: textTheme.labelLarge,
                ),
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
