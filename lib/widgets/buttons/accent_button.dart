import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:flutter/material.dart';

class AccentButton extends StatelessWidget {
  final String? label;
  final Function()? callback;

  const AccentButton({Key? key, this.label, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        child: Text(label!, style: TextStyle(fontSize: 14)),
        onPressed: callback != null ? () =>
            lockHelper.provideWithLockChecker(context, () => callback!()) : null,
      ),
    );
  }
}
