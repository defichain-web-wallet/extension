import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatButton extends StatelessWidget with ThemeMixin {
  final void Function()? callback;
  final String title;
  final String? iconPath;
  final bool isPrimary;
  final bool isSmall;

  FlatButton({
    Key? key,
    this.callback,
    this.iconPath,
    required this.title,
    this.isPrimary = true,
    this.isSmall = false,
  }) : super(key: key);

  static const double mediumHeight = 48.0;
  static const double largeHeight = 54.0;

  MaterialStatePropertyAll<Color> getSpecificBackgroundColor() {
    if (isPrimary && callback != null) {
      return MaterialStatePropertyAll(
        AppColors.purplePizzazz.withOpacity(0.1),
      );
    } else if (callback == null) {
      return MaterialStatePropertyAll(
        AppColors.portage.withOpacity(0.15),
      );
    } else {
      return MaterialStatePropertyAll(
        (isDarkTheme()) ? Colors.transparent : Colors.white,
      );
    }
  }

  Color? getSpecificIconColor() {
    if (isPrimary) {
      return null;
    } else {
      return isDarkTheme() ? Colors.white : AppColors.darkTextColor;
    }
  }

  Color getSpecificBorderColor() {
    return (isPrimary)
        ? Colors.transparent
        : AppColors.lavenderPurple.withOpacity(0.32);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isPrimary ? largeHeight : mediumHeight,
      child: ElevatedButton(
        onPressed: callback,
        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
              backgroundColor: getSpecificBackgroundColor(),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(buttonBorderRadius),
                  ),
                  side: BorderSide(
                    color: getSpecificBorderColor(),
                  ),
                ),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconPath != null)
              Container(
                width: isPrimary ? 16 : 14,
                height: isPrimary ? 16 : 14,
                child: (isPrimary) ? Image.asset(iconPath!) : SvgPicture.asset(
                  iconPath!,
                  color: isDarkTheme() ? Colors.white : AppColors.darkTextColor,
                ),
              ),
            if (!isSmall)
              ...[
                SizedBox(
                  width: 6.4,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.button!.copyWith(
                    fontSize: 13,
                    color: (callback == null)
                          ? Theme.of(context)
                              .textTheme
                              .button!
                              .color!
                              .withOpacity(0.2)
                          : Theme.of(context).textTheme.button!.color!,
                    ),
                )
              ]
          ],
        ),
      ),
    );
  }
}
