import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dotted_tab.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';

class ConnectLedgerThirdScreen extends StatefulWidget {
  final void Function() callback;

  const ConnectLedgerThirdScreen({Key? key, required this.callback})
      : super(key: key);

  @override
  State<ConnectLedgerThirdScreen> createState() =>
      _ConnectLedgerThirdScreenState();
}

class _ConnectLedgerThirdScreenState extends State<ConnectLedgerThirdScreen>
    with ThemeMixin {
  String subtitleText =
      'If your Ledger is broken/lost you will need a replacement device with your Ledger recovery phrase.';
  String titleText = '3.';

  initState() {
    super.initState();

    jellyLedgerInit();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StretchBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/defi_ledger_seed_phrase.png',
              width: 202.94,
              height: 176.44,
            ),
            Container(
              child: Column(
                children: [
                  DottedTab(
                    tabLenth: 4,
                    selectTabIndex: 3,
                  ),
                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    '$titleText Connect',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 80,
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
                        callback: () {
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
