import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class AppTooltip extends StatelessWidget with ThemeMixin {
  final Widget child;
  final String message;

  AppTooltip({
    Key? key,
    required this.child,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: isDarkTheme()
            ? DarkColors.drawerBgColor
            : LightColors.drawerBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.whiteLilac,
        ),
      ),
      textStyle: Theme.of(context)
          .textTheme
          .subtitle2!
          .copyWith(
        color: Theme.of(context)
            .textTheme
            .subtitle2!
            .color!
            .withOpacity(0.5),
        fontSize: 10,
      ),
      message: message,
      child: child,
    );
  }
}
