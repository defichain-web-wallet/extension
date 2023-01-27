import 'dart:ui';
import 'dart:math' as math;
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class LedgerErrorDialog extends StatefulWidget {
  final Exception? error;
  final Function() callbackOk;
  final Function() callbackTryAgain;

  const LedgerErrorDialog({Key? key, required this.error, required this.callbackOk, required this.callbackTryAgain}) : super(key: key);

  @override
  State<LedgerErrorDialog> createState() => _LedgerErrorDialogState();
}

class _LedgerErrorDialogState extends State<LedgerErrorDialog> {
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;
  String subtitleTextOops = 'Something went wrong, Jelly couldn\'t communicate with your ledger. Make sure you have connected your ledger and opened the DeFiChain application!';

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
              height: 339,
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
                    'Oops!',
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.headline5!.color,
                        ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    subtitleTextOops,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.6),
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
