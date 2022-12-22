import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlatButton extends StatelessWidget with ThemeMixin {
  final void Function()? callback;
  final String title;
  final String? iconPath;
  final bool isPrimary;

  FlatButton({
    Key? key,
    this.callback,
    this.iconPath,
    required this.title,
    this.isPrimary = true,
  }) : super(key: key);

  static const double mediumHeight = 48.0;
  static const double largeHeight = 54.0;

  MaterialStatePropertyAll<Color> getSpecificBackgroundColor() {
    if (isPrimary) {
      return MaterialStatePropertyAll(
        AppColors.purplePizzazz.withOpacity(0.1),
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
                width: isPrimary ? 22 : 20,
                height: isPrimary ? 22 : 20,
                padding: const EdgeInsets.only(right: 6.4),
                child: SvgPicture.asset(
                  iconPath!,
                  color: getSpecificIconColor(),
                ),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.button!.copyWith(
                    fontSize: isPrimary ? 14 : 12,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
