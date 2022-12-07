import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class AccentButton extends StatelessWidget {
  final String? label;
  final Function()? callback;

  const AccentButton({Key? key, this.label, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: Color(0xFF9988BE).withOpacity(0.32),
              ),
            ),
          ),
        ),
        child: Text(label!, style: TextStyle(fontSize: 14)),
        onPressed: callback != null
            ? () =>
                lockHelper.provideWithLockChecker(context, () => callback!())
            : null,
      ),
    );
  }
}
