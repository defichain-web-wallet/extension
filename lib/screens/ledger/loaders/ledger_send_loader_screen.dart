import 'dart:async';

import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';

class LedgerSendLoaderScreen extends StatefulWidget {
  final Function()? callback;
  String currentStatus;

  LedgerSendLoaderScreen({
    Key? key,
    this.callback,
    this.currentStatus = 'first-step',
  }) : super(key: key);

  @override
  State<LedgerSendLoaderScreen> createState() => _LedgerSendLoaderScreenState();
}

class _LedgerSendLoaderScreenState extends State<LedgerSendLoaderScreen>
    with ThemeMixin {
  String firstStepText = 'Jelly is quickly removing some seaweed';
  String secondStepText = 'Almost done';
  String thirdStepText = 'Argh.. Blockchains are not the fastest!';
  String currentText = '';
  String warningText = 'Jelly don’t recommend to unplug Ledger!';
  double loaderImageWidth = 54;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    if (widget.currentStatus == 'first-step') {
      currentText = firstStepText;
    }
    if (widget.currentStatus == 'first-step') {
      timer = Timer.periodic(Duration(seconds: 3), (_timer) {
        getStatusText(widget.currentStatus, _timer);
        print('Timer TICK');
        // if (widget.currentStatus == 'third-step') {
        //   _timer.cancel();
        // }
      });
    }
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: NewMainAppBar(
            isShowLogo: true,
          ),
          body: Container(
            padding: EdgeInsets.only(
              top: 59,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDarkTheme()
                  ? DarkColors.scaffoldContainerBgColor
                  : LightColors.scaffoldContainerBgColor,
              border: isDarkTheme()
                  ? Border.all(
                      width: 1.0,
                      color: Colors.white.withOpacity(0.05),
                    )
                  : null,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/defi_love_ledger.png',
                              width: 304.99,
                              height: 247.3,
                            ),
                            SizedBox(
                              width: 23,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Image.asset(
                          isDarkTheme()
                              ? 'assets/images/loader_dark_bg.gif'
                              : 'assets/images/loader_white_bg.gif',
                          width: loaderImageWidth,
                        ),
                        SizedBox(
                          height: 39,
                        ),
                        Container(
                          height: 37,
                          child: Text(
                            currentText,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.6),
                                    ),
                          ),
                        ),
                        Container(
                          height: 116,
                          child: Text(
                            warningText,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      color: AppColors.pinkColor,
                                    ),
                          ),
                        ),
                      ],
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
      });
    }
    if (currentStatus == 'third-step') {
      timer.cancel();
      widget.callback!();
    }
  }
}
