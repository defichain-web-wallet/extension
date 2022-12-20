import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class NewPrimaryButton extends StatelessWidget {
  final void Function()? callback;
  final double width;
  final String title;

  NewPrimaryButton(
      {Key? key,
      this.callback,
      this.width = double.infinity,
      this.title = 'OK'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonBorderRadius),
        gradient: callback != null ? gradientButton : gradientDisableButton
      ),
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(buttonBorderRadius),
            ),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.button!.apply(
            color: Color(0xFFFCFBFE),
            fontWeightDelta: 1,
          ),
        ),
      ),
    );
  }
}
