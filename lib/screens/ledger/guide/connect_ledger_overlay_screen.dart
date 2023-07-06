import 'dart:ui';

import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/ledger/guide/connect_ledger_first_screen.dart';
import 'package:defi_wallet/screens/ledger/guide/connect_ledger_fourth_screen.dart';
import 'package:defi_wallet/screens/ledger/guide/connect_ledger_second_screen.dart';
import 'package:defi_wallet/screens/ledger/guide/connect_ledger_third_screen.dart';
import 'package:defi_wallet/screens/ledger/loaders/ledger_auth_loader_screen.dart';
import 'package:flutter/material.dart';

class ConnectLedgerOverlayScreen extends StatefulWidget {
  const ConnectLedgerOverlayScreen({Key? key}) : super(key: key);

  @override
  State<ConnectLedgerOverlayScreen> createState() =>
      _ConnectLedgerOverlayScreenState();
}

class _ConnectLedgerOverlayScreenState extends State<ConnectLedgerOverlayScreen>
    with ThemeMixin {
  int currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: AlertDialog(
            content: Container(
                padding: EdgeInsets.only(
                  top: 27,
                  bottom: 24,
                  left: 16,
                  right: 16,
                ),
                child: getCurrentStep())));
  }

  Widget getCurrentStep() {
    if (currentStep == 1) {
      return new ConnectLedgerFirstScreen(
          callback: () => {setState(() => this.currentStep = 2)});
    } else if (currentStep == 2) {
      return new ConnectLedgerSecondScreen(
          callback: () => {setState(() => this.currentStep = 3)});
    } else if (currentStep == 3) {
      return new ConnectLedgerThirdScreen(
          callback: () => {setState(() => this.currentStep = 4)});
    } else if (currentStep == 4) {
      return new ConnectLedgerFourthScreen(
          callback: () => {setState(() => this.currentStep = 5)});
    } else if (currentStep == 5) {
      return new LedgerAuthLoaderScreen(
          callback: () => {setState(() => this.currentStep = 6)},
          errorCallback: () => {setState(() => this.currentStep = 4)});
    } else if (currentStep == 6) {
      Navigator.pop(context);
    }
    return Container();
  }
}
