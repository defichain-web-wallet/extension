import 'dart:ui';

import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/ledger/ledger_error_dialog.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dotted_tab.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';
import 'package:js/js_util.dart';

class ConnectLedgerFourthScreen extends StatefulWidget {
  final void Function() callback;

  const ConnectLedgerFourthScreen({Key? key, required this.callback})
      : super(key: key);

  @override
  State<ConnectLedgerFourthScreen> createState() =>
      _ConnectLedgerFourthScreenState();
}

class _ConnectLedgerFourthScreenState extends State<ConnectLedgerFourthScreen>
    with ThemeMixin {
  String subtitleText =
      'Once you set up the wallet with Ledger you can only use Jellywallet with Ledger.';
  String titleText = '4.';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StretchBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 29,
                ),
                Image.asset(
                  'assets/images/defi_ledger_screen.png',
                  width: 268.7,
                  height: 247.3,
                ),
                // SizedBox(
                //   width: 23,
                // ),
              ],
            ),
            Container(
              child: Column(
                children: [
                  DottedTab(
                    tabLenth: 4,
                    selectTabIndex: 4,
                  ),
                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    '$titleText Connect Ledger',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 105,
                    child: Text(
                      subtitleText,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                        callback: () async {
                          var usbSupported =
                              await promiseToFuture(isUsbSupported());

                          if (usbSupported > 0) {
                            await showDialog(
                              barrierColor: AppColors.tolopea.withOpacity(0.06),
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return LedgerErrorDialog(
                                    error: new Exception(usbSupported == 1
                                        ? "USB_NOT_ALLOWED_IN_POPUP"
                                        : "NO_USB_DEVICE_SELECTED"));
                              },
                            );
                            if (usbSupported == 1) {
                              openInTab();
                            }
                            return;
                          }
                          this.widget.callback();
                        },
                        title: 'Next',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
