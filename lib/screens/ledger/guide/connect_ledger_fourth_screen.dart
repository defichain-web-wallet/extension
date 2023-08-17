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

class LedgerAppName {
  String appName;
  String title;

  LedgerAppName(this.appName, this.title);
}

class ConnectLedgerFourthScreen extends StatefulWidget {
  final void Function(String appName) callback;

  const ConnectLedgerFourthScreen({Key? key, required this.callback})
      : super(key: key);

  @override
  State<ConnectLedgerFourthScreen> createState() =>
      _ConnectLedgerFourthScreenState();
}

class _ConnectLedgerFourthScreenState extends State<ConnectLedgerFourthScreen>
    with ThemeMixin {
  String subtitleText =
      'Please select the network you want to connect. Ensure that your ledger is connected, unlocked and the correct app is open.';
  String titleText = '4.';

  List<LedgerAppName> apps = List<LedgerAppName>.empty(growable: true);

  initState() {
    super.initState();

    apps.add(LedgerAppName("btc", "Bitcoin"));
    apps.add(LedgerAppName("test", "Bitcoin Testnet"));

    //for later use!
    //apps.add(LedgerAppName("dfi", "DeFiChain"));
    //apps.add(LedgerAppName("dfitest", "DeFiChain Testnet"));
    selectedApp = apps.first;
  }

  LedgerAppName? selectedApp;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StretchBox(
          child: SingleChildScrollView(
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
                  width: 202.94,
                  height: 176.44,
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
                    // height: 105,
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
                  ListTile(
                    title: const Text('Bitcoin'),
                    tileColor: Colors.transparent,
                    leading: Radio<LedgerAppName>(
                      value: apps[0],
                      groupValue: selectedApp,
                      fillColor: MaterialStateColor.resolveWith(
                          (states) => AppColors.pink),
                      onChanged: (LedgerAppName? value) {
                        setState(() {
                          selectedApp = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Bitcoin Testnet'),
                    tileColor: Colors.transparent,
                    leading: Radio<LedgerAppName>(
                      value: apps[1],
                      groupValue: selectedApp,
                      fillColor: MaterialStateColor.resolveWith(
                          (states) => AppColors.pink),
                      onChanged: (LedgerAppName? value) {
                        setState(() {
                          selectedApp = value!;
                        });
                      },
                    ),
                  ),
                  Container(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        child: AccentButton(
                          callback: () {
                            Navigator.pop(context);
                          },
                          label: 'Cancel',
                        ),
                      ),
                      NewPrimaryButton(
                        width: 80,
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
                          this.widget.callback(this.selectedApp!.appName);
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
      )),
    );
  }
}
