import 'dart:async';

import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';

class LedgerConfirmLoading extends StatefulWidget {
  String currentStatus;

  LedgerConfirmLoading({Key? key, this.currentStatus = 'first-step'})
      : super(key: key);

  @override
  State<LedgerConfirmLoading> createState() => _LedgerConfirmLoadingState();
}

class _LedgerConfirmLoadingState extends State<LedgerConfirmLoading> {
  String firstStepText = 'Jelly is quickly removing some seaweed';
  String secondStepText = 'Almost done..';
  String thirdStepText = 'Argh.. Blockchains are not the fastest!';
  String currentText = '';

  @override
  Widget build(BuildContext context) {
    print(widget.currentStatus);
    if (widget.currentStatus == 'first-step') {
      currentText = firstStepText;
    }
    Timer(Duration(seconds: 5), () {
      getStatusText(widget.currentStatus);
    });
    return ScaffoldConstrainedBox(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                title: 'Processing',
              ),
              body: _buildBody(),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  isSmall: true,
                  title: 'Processing',
                ),
                body: _buildBody(isFullSize: true),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody({isFullSize = false}) {
    return Container(
      color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
      padding: const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
      child: Center(
        child: StretchBox(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      SettingsHelper.settings.theme == 'Light'
                          ? isFullSize
                              ? 'assets/images/ledger_loading_light_white.gif'
                              : 'assets/images/ledger_loading_light_gray.gif'
                          : isFullSize
                              ? 'assets/images/ledger_loading_dark.gif'
                              : 'assets/images/ledger_loading_dark.gif',
                      width: 180,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      currentText,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getStatusText(currentStatus) {
    if (currentStatus == 'first-step') {
      setState(() {
        widget.currentStatus = 'second-step';
        currentText = secondStepText;
      });
    }
    if (currentStatus == 'second-step') {
      setState(() {
        widget.currentStatus = 'third-step';
        currentText = thirdStepText;
      });
    }
    if (currentStatus == 'third-step') {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
