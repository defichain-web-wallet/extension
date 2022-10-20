import 'dart:async';

import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';

import 'package:flutter/material.dart';

class LoaderScreen extends StatefulWidget {
  final String secondStepLoaderText;
  final String title;
  bool isFullSize;
  String currentStatus;
  Function()? callback;

  LoaderScreen({
    Key? key,
    required this.secondStepLoaderText,
    required this.title,
    this.callback,
    this.isFullSize = false,
    this.currentStatus = 'first-step',
  }) : super(key: key);

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  String firstStepText = 'One second, Jelly is preparing your transaction!';
  String secondStepText = '';
  String thirdStepText = 'Argh... Blockchains are not the fastest!';
  String currentText = '';
  double loaderImageWidth = 180;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        secondStepText = widget.secondStepLoaderText;
        if (widget.currentStatus == 'first-step') {
          currentText = firstStepText;
        }
        if (widget.currentStatus == 'first-step') {
          timer = Timer.periodic(Duration(seconds: 3), (_timer) {
            getStatusText(widget.currentStatus, _timer);
            if (widget.currentStatus == 'third-step') {
              _timer.cancel();
            }
          });
        }
        return Scaffold(
          appBar: MainAppBar(
            isShowNavButton: false,
            title: widget.title,
            action: null,
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                                ? widget.isFullSize
                                    ? 'assets/images/ledger_loading_light_white.gif'
                                    : 'assets/images/ledger_loading_light_gray.gif'
                                : widget.isFullSize
                                    ? 'assets/images/ledger_loading_dark.gif'
                                    : 'assets/images/ledger_loading_dark.gif',
                            width: loaderImageWidth,
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
          ),
        );
      },
    );
  }

  getStatusText(currentStatus, timer) async {
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
        timer.cancel();
        widget.callback!();
      });
    }
  }
}
