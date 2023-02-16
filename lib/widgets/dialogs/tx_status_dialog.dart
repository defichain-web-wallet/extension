import 'dart:ui';

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/status_logo_and_title.dart';
import 'package:flutter/material.dart';

class TxStatusDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final TxErrorModel? txResponse;
  final Function() callbackOk;
  final Function() callbackTryAgain;
  final bool isSuccess;

  const TxStatusDialog({
    Key? key,
    this.title = 'Success!',
    this.subtitle =
        'Jelly is now processing your transaction in the background. Your account balance will be updated in a few minutes.',
    this.buttonLabel = 'OK',
    required this.txResponse,
    required this.callbackOk,
    required this.callbackTryAgain,
    this.isSuccess = false,
  }) : super(key: key);

  @override
  State<TxStatusDialog> createState() => _TxStatusDialogState();
}

class _TxStatusDialogState extends State<TxStatusDialog> with ThemeMixin {
  String subtitleTextOops =
      'Something went wrong, Jelly couldn\'t process your transaction. Please try again!';
  String subtitleTextSuccsess =
      'Jelly is now processing your transaction in the background. Your account balance will be updated in a few minutes.';

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        insetPadding: EdgeInsets.all(24),
        elevation: 48.0,
        backgroundColor: isDarkTheme()
            ? DarkColors.networkDropdownBgColor
            : LightColors.scaffoldContainerBgColor,
        shape: RoundedRectangleBorder(
          side: isDarkTheme()
              ? BorderSide(
                  color: Colors.white.withOpacity(0.05),
                )
              : BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        actionsPadding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 14,
        ),
        actions: [
          if (!widget.txResponse!.isError!)
            Center(
              child: NewPrimaryButton(
                width: buttonSmallWidth,
                callback: () {
                  Navigator.pop(context);
                  widget.callbackOk();
                },
                title: widget.buttonLabel,
              ),
            ),
          if (widget.txResponse!.isError!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 104,
                  child: AccentButton(
                    callback: () {
                      Navigator.pop(context);
                    },
                    label: 'Cancel',
                  ),
                ),
                NewPrimaryButton(
                  width: 104,
                  callback: () {
                    Navigator.pop(context);
                    widget.callbackTryAgain();
                  },
                  title: 'Try again',
                ),
              ],
            ),
        ],
        contentPadding: EdgeInsets.only(
          top: 16,
          bottom: 0,
          left: 16,
          right: 16,
        ),
        content: Stack(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 312),
              width: 312,
              height: !widget.txResponse!.isError! ? 339 : 319,
              child: StatusLogoAndTitle(
                title:
                    !widget.txResponse!.isError! ? widget.title : 'Oops!',
                subtitle: !widget.txResponse!.isError!
                    ? widget.subtitle
                    : subtitleTextOops,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
