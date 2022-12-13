import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final void Function()? callback;
  final String title;
  final Widget? icon;
  final bool isPrimary;

  FlatButton({
    Key? key,
    this.callback,
    this.icon,
    required this.title,
    this.isPrimary = true,
  }) : super(key: key);

  static const double mediumHeight = 48.0;
  static const double largeHeight = 54.0;

  MaterialStatePropertyAll<Color> getSpecificBackgroundColor() {
    return MaterialStatePropertyAll(
      (isPrimary) ? AppColors.purplePizzazz.withOpacity(0.1) : Colors.white,
    );
  }

  Color getSpecificBorderColor() {
    return (isPrimary)
        ? Colors.white
        : AppColors.lavenderPurple.withOpacity(0.32);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isPrimary ? largeHeight : mediumHeight,
      child: ElevatedButton(
        onPressed: callback,
        style: Theme
            .of(context)
            .outlinedButtonTheme
            .style!
            .copyWith(
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
            if (icon != null)
              Container(
                width: 22,
                height: 22,
                padding: const EdgeInsets.only(right: 6.4),
                child: icon!,
              ),
            Text(
              title,
              style: Theme
                  .of(context)
                  .textTheme
                  .button!,
            )
          ],
        ),
      ),
    );
  }
}
