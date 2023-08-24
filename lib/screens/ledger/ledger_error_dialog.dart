import 'dart:math' as math;
import 'dart:ui';

import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:flutter/material.dart';

class LedgerErrorDialog extends StatefulWidget {
  final Object? error;

  const LedgerErrorDialog({Key? key, required this.error}) : super(key: key);

  @override
  State<LedgerErrorDialog> createState() => _LedgerErrorDialogState();
}

class _LedgerErrorDialogState extends State<LedgerErrorDialog> {
  final double _logoWidth = 210.0;
  final double _logoHeight = 200.0;
  final double _logoRotateDeg = 17.5;
  String subtitleTextOops =
      'Something went wrong, Jelly couldn\'t communicate with your ledger. Make sure you have connected your ledger and opened the correct application!';
  String deviceLocked =
      'Something went wrong, Jelly detected that your ledger is still locked. Please unlock your ledger and retry!';
  String transactionAborted =
      'Something went wrong, Jelly detected that you have aborted the transaction.';
  String usbNotAllowedInPopup =
      'Usb selection is not allowed in popup mode. We need to open Jellywallet in a tab. Jelly is taking care of it for you!';
  String noUsbDeviceSelected =
      'Jelly detected that you did not select any USB device. Please select and allow an USB connection to continue!';
  String couldNotClaimUsbDevice =
      'Jelly could not claim your ledger. Please check if some other application is using the device.';
  String deviceAlreadyOpened =
      'Jelly could not connect your ledger. Please refresh the wallet and try again.';

  late String errorMessage;

  @override
  initState() {
    super.initState();
    errorMessage = subtitleTextOops;

    if (widget.error.toString().contains("0x6982")) {
      //device locked!
      errorMessage = deviceLocked;
    } else if (widget.error.toString().contains("0x6985")) {
      //transaction rejected by user
      errorMessage = transactionAborted;
    } else if (widget.error.toString().contains("USB_NOT_ALLOWED_IN_POPUP")) {
      //usb not allowed in popup mode!
      errorMessage = usbNotAllowedInPopup;
    } else if (widget.error.toString().contains("NO_USB_DEVICE_SELECTED")) {
      errorMessage = noUsbDeviceSelected;
    } else if (widget.error.toString().contains("claim")) {
      errorMessage = noUsbDeviceSelected;
    } else if (widget.error
        .toString()
        .contains("The device is already open.")) {
      errorMessage = deviceAlreadyOpened;
    }
  }

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 104,
                child: AccentButton(
                  callback: () {
                    Navigator.pop(context);
                  },
                  label: 'Ok',
                ),
              )
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
                    errorMessage,
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
