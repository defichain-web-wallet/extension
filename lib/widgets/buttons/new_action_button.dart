import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewActionButton extends StatefulWidget {
  final String iconPath;
  final Function()? onPressed;
  final bool isStaticColor;
  final bool isSvg;
  final LinearGradient? bgGradient;
  final double width;
  final double height;

  const NewActionButton({
    Key? key,
    required this.iconPath,
    this.onPressed,
    this.isStaticColor = false,
    this.isSvg = true,
    this.bgGradient,
    this.width = 32,
    this.height = 32,
  }) : super(key: key);

  @override
  State<NewActionButton> createState() => _NewActionButtonState();
}

class _NewActionButtonState extends State<NewActionButton>  with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return Container(
      width: widget.width,
      height: widget.height,
      // backgroundColor: AppTheme.iconButtonBackground,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.bgGradient != null ? null : AppTheme.iconButtonBackground,
        gradient: widget.bgGradient,
      ),
      child: IconButton(
        splashRadius: 1,
        iconSize: 16,
        icon: widget.isSvg
            ? SvgPicture.asset(
                widget.iconPath,
                width: widget.width / 2,
                height: widget.height / 2,
                color: widget.isStaticColor
                    ? null
                    : isDarkTheme()
                        ? Colors.white
                        : null,
              )
            : Image.asset(
                widget.iconPath,
                width: widget.width / 2,
                height: widget.height / 2,
              ),
        onPressed: () =>
            lockHelper.provideWithLockChecker(context, () => widget.onPressed!()),
      ),
    );
  }
}
