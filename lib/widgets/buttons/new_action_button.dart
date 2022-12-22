import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewActionButton extends StatefulWidget {
  final String iconPath;
  final Function()? onPressed;

  const NewActionButton({Key? key, required this.iconPath, this.onPressed})
      : super(key: key);

  @override
  State<NewActionButton> createState() => _NewActionButtonState();
}

class _NewActionButtonState extends State<NewActionButton>  with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.iconButtonBackground,
      child: IconButton(
        splashRadius: 1,
        iconSize: 16,
        icon: SvgPicture.asset(
          widget.iconPath,
          width: 16,
          height: 16,
          color: isDarkTheme() ? Colors.white : null,
        ),
        onPressed: () =>
            lockHelper.provideWithLockChecker(context, () => widget.onPressed!()),
      ),
    );
  }
}
