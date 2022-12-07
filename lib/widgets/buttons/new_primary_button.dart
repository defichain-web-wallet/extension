import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class NewPrimaryButton extends StatelessWidget {
  void Function()? callback;
  double width;
  String title;

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
        gradient: LinearGradient(
          colors: callback != null
              ? [
                  Color(0xFFBC00C0),
                  Color(0xFFFF00A3),
                ]
              : [
                  Color(0xFFecb2ec),
                  Color(0xFFffb2e3),
                ],
        ),
      ),
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          side: BorderSide(
            style: BorderStyle.solid,
            color: Color(0xFFd1a5dd),
          ),
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
