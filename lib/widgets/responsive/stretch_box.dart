import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';

class StretchBox extends StatelessWidget {
  static const double defaultMaxWidth = ScreenSizes.small;
  static const double defaultMinWidth = ScreenSizes.xSmall;

  final Widget? child;
  final double maxWidth;
  final double minWidth;

  const StretchBox(
      {Key? key,
      this.child,
      this.minWidth = defaultMinWidth,
      this.maxWidth = defaultMaxWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: minWidth,
      ),
      child: child,
    );
  }
}
