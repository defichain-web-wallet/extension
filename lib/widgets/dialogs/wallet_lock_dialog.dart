import 'dart:ui';
import 'dart:math' as math;

import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';

class WalletLockDialog extends StatefulWidget {
  final Function() callback;

  const WalletLockDialog({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  State<WalletLockDialog> createState() => _WalletLockDialogState();
}

class _WalletLockDialogState extends State<WalletLockDialog> {
  String subtitleText = 'Are you sure you want to lock your wallet? '
      'Enter your passcode in the next step.';
  String title = 'Lock wallet';
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;

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
                  widget.callback();
                },
                title: 'Yes, Lock',
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
              height: 319,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 230,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            child: Align(
                              alignment: Alignment.center,
                              child: Transform.rotate(
                                angle: -math.pi * 2 + 0.05,
                                child: Container(
                                  height: 180,
                                  width: 150,
                                  child: Image(
                                    image: AssetImage(
                                      'assets/images/lock_image.png',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 104,
                            right: 150,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Transform.rotate(
                                angle: -math.pi / _logoRotateDeg-0.1,
                                child: Container(
                                  height: 110,
                                  width: 105,
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
                    ),
                    Text(
                      'Lock wallet',
                      style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.headline5!.color,
                          ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      subtitleText,
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
