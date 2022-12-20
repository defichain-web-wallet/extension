import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewActionButton extends StatelessWidget {
  final String iconPath;
  final Function()? onPressed;

  const NewActionButton({Key? key, required this.iconPath, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.iconButtonBackground,
        child: IconButton(
          splashRadius: 1,
          iconSize: 18,
          icon: SvgPicture.asset(
            iconPath,
            width: 18,
            height: 18,
          ),
          onPressed: () =>
              lockHelper.provideWithLockChecker(context, () => onPressed!()),
        ),
      ),
    );
  }
}
