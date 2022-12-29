import 'dart:ui';
import 'dart:math' as math;

import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class TxStatusDialog extends StatefulWidget {
  final TxErrorModel? txResponse;
  final Function() callbackOk;
  final Function() callbackTryAgain;
  final bool isSuccess;

  const TxStatusDialog({
    Key? key,
    required this.txResponse,
    required this.callbackOk,
    required this.callbackTryAgain,
    this.isSuccess = false,
  }) : super(key: key);

  @override
  State<TxStatusDialog> createState() => _TxStatusDialogState();
}

class _TxStatusDialogState extends State<TxStatusDialog> {
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;
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
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        actionsPadding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 14,
        ),
        actions: [
          if(!widget.txResponse!.isError)Center(
            child: NewPrimaryButton(
              width: buttonSmallWidth,
              callback: () {
                Navigator.pop(context);
                widget.callbackOk();
              },
              title: 'OK',
            ),
          ),
          if(widget.txResponse!.isError)Row(
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
              height: !widget.txResponse!.isError ? 339 : 319,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        child: Align(
                          alignment: Alignment.center,
                          child: Transform.rotate(
                            angle: -math.pi / _logoRotateDeg,
                            child: Container(
                              height: _logoWidth,
                              width: _logoHeight,
                              child: Image(
                                image: AssetImage(
                                  'assets/welcome_logo.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    !widget.txResponse!.isError ?  'Success!' : 'Oops!',
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.headline5!.color,
                        ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    !widget.txResponse!.isError ? subtitleTextSuccsess : subtitleTextOops,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .headline5!
                              .color!
                              .withOpacity(0.6),
                        ),
                  )
                ],
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
