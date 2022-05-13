import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';

class MenuHelper {
  double getHorizontalMargin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double horizontalMargin = 15;

    if (width > ScreenSizes.medium) {
      horizontalMargin += ((width - ScreenSizes.medium) / 2).round();
    }

    return horizontalMargin;
  }
}