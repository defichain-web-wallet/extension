import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class SmallPrimaryButton extends StatelessWidget {
  final String? label;
  final GlobalKey? globalKey;
  final Function()? callback;
  final bool? isCheckLock;

  const SmallPrimaryButton({
    Key? key,
    this.label,
    this.globalKey,
    this.callback,
    this.isCheckLock = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();
    return Container(
      width: 90,
      height: 26,
      child: ElevatedButton(
        key: globalKey,
        onPressed: isCheckLock!
            ? () =>
            lockHelper.provideWithLockChecker(context, () => callback!())
            : callback,
        child: Text(
          label!,
        ),
        style: ElevatedButton.styleFrom(
          primary: AppTheme.pinkColor,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: Theme.of(context).textTheme.headline4!.apply(
            color: Colors.white,
          ),
          shadowColor: Colors.black.withOpacity(0.35),
          elevation: 8,
        ),
      ),
    );
  }
}
