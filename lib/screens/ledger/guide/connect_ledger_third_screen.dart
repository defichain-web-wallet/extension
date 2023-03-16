import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/ledger/guide/connect_ledger_fourth_screen.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/dotted_tab.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';

class ConnectLedgerThirdScreen extends StatefulWidget {
  const ConnectLedgerThirdScreen({Key? key}) : super(key: key);

  @override
  State<ConnectLedgerThirdScreen> createState() => _ConnectLedgerThirdScreenState();
}

class _ConnectLedgerThirdScreenState extends State<ConnectLedgerThirdScreen> with ThemeMixin {
  String subtitleText = 'If your Ledger is lost or defect you will need to set up a replacement device with your recovery phrase obtained through Ledger itself.';
  String titleText = '3.';

  initState() {
    super.initState();

    jellyLedgerInit();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(
            progress: 0.3,
          ),
          body: Container(
            padding: EdgeInsets.only(
              top: 40,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/defi_ledger_seed_phrase.png',
                          width: 303.87,
                          height: 247.3,
                        ),
                        SizedBox(
                          width: 24,
                        ),
                      ],
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
                                    color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.6),
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
                                  label: 'Back',
                                ),
                              ),
                              NewPrimaryButton(
                                width: 104,
                                callback: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation1, animation2) => ConnectLedgerFourthScreen(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
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
            ),
          ),
        );
      },
    );
  }
}
