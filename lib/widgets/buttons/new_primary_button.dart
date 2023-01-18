import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class NewPrimaryButton extends StatelessWidget {
  void Function()? callback;
  double width;
  String title;
  Widget? titleWidget;

  NewPrimaryButton({
    Key? key,
    this.callback,
    this.width = double.infinity,
    this.title = 'OK',
    this.titleWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: callback == null
          ? SystemMouseCursors.click
          : SystemMouseCursors.click,
      child: Container(
        height: buttonHeight,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            gradient: callback != null ? gradientButton : gradientDisableButton),
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
          child: titleWidget != null ? titleWidget : Text(
            title,
            style: Theme.of(context).textTheme.button!.apply(
                  color: Color(0xFFFCFBFE),
                  fontWeightDelta: 1,
                ),
          ),
        ),
      ),
    );
  }
}
