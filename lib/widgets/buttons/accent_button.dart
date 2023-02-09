import 'dart:ui';

import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class AccentButton extends StatelessWidget with ThemeMixin {
  final String? label;
  final Function()? callback;
  final bool isCheckLock;
  final bool isOpasity;

  AccentButton({
    Key? key,
    this.label,
    this.callback,
    this.isCheckLock = true,
    this.isOpasity = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 1.5,
            sigmaY: 1.5,
          ),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                isOpasity
                    ? Color(0xff030A53).withOpacity(0.33)
                    : isDarkTheme()
                        ? DarkColors.accentButtonBgColor
                        : LightColors.accentButtonBgColor,
              ),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(accentButtonBorderRadius),
                  side: BorderSide(
                    color: Color(0xFF9988BE).withOpacity(0.32),
                  ),
                ),
              ),
            ),
            child: Text(label!, style: Theme.of(context).textTheme.button!.copyWith(
              color: isOpasity ? Colors.white : Theme.of(context).textTheme.button!.color
            )),
            onPressed: callback != null
                ? () {
                    if (isCheckLock) {
                      lockHelper.provideWithLockChecker(context, () => callback!());
                    } else {
                      callback!();
                    }
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
