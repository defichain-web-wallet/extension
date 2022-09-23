import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class SlippageButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Function() callback;
  final bool isBorder;
  final bool isFirst;
  final bool isLast;

  const SlippageButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.callback,
    this.isBorder = false,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: TextButton(
        style: TextButton.styleFrom(
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.all(0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: isFirst
                ? BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  )
                : BorderRadius.circular(0),
            side: BorderSide(
              color: Colors.transparent,
            ),
          ),
          backgroundColor:
              isActive ? AppTheme.pinkColor : Theme.of(context).backgroundColor,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headline4!.apply(
                fontSizeFactor: 0.9,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.headline4!.color,
              ),
        ),
        onPressed: callback,
      ),
    );
  }
}
