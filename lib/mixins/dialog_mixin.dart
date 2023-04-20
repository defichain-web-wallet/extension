import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

mixin DialogMixin {
  Future showAppDialog(Widget widget, BuildContext context) {
    return showDialog(
      barrierColor: AppColors.tolopea.withOpacity(0.06),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return widget;
      },
    );
  }
}
