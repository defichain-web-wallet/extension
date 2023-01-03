import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewActionButton extends StatefulWidget {
  final String iconPath;
  final Function()? onPressed;
  final bool isStaticColor;
  final LinearGradient? bgGradient;

  const NewActionButton({
    Key? key,
    required this.iconPath,
    this.onPressed,
    this.isStaticColor = false,
    this.bgGradient,
  }) : super(key: key);

  @override
  State<NewActionButton> createState() => _NewActionButtonState();
}

class _NewActionButtonState extends State<NewActionButton>  with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return Container(
      width: 32,
      height: 32,
      // backgroundColor: AppTheme.iconButtonBackground,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.bgGradient != null ? null : AppTheme.iconButtonBackground,
        gradient: widget.bgGradient,
      ),
      child: IconButton(
        splashRadius: 1,
        iconSize: 16,
        icon: SvgPicture.asset(
          widget.iconPath,
          width: 16,
          height: 16,
          color: widget.isStaticColor
              ? null
              : isDarkTheme()
                  ? Colors.white
                  : null,
        ),
        onPressed: () =>
            lockHelper.provideWithLockChecker(context, () => widget.onPressed!()),
      ),
    );
  }
}
