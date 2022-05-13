import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? label;
  final GlobalKey? globalKey;
  final Function()? callback;
  final bool? isCheckLock;

  const PrimaryButton(
      {Key? key,
      this.label,
      this.globalKey,
      this.callback,
      this.isCheckLock = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        child: Text(label!),
        key: globalKey,
        onPressed: isCheckLock!
            ? () =>
                lockHelper.provideWithLockChecker(context, () => callback!())
            : callback,
        style: AppTheme.defiButton,
      ),
    );
  }
}
