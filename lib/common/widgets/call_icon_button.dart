import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/device/launcher_utils.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';

/// Opens the dialer. Used on customer rows and the detail screen.
class CallIconButton extends StatelessWidget {
  final String phone;
  final Color iconColor;
  const CallIconButton({
    super.key,
    required this.phone,
    this.iconColor = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.call_outlined,
      color: iconColor,
      backgroundColor: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
      tooltip: 'Call',
      onPressed: () async {
        final ok = await LauncherUtils.call(phone);
        if (!ok && context.mounted) {
          AppSnackbar.error(context, 'Unable to open dialer');
        }
      },
    );
  }
}
