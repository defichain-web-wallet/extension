import 'dart:async';

import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';

class LoaderNew extends StatefulWidget {
  final String secondStepLoaderText;
  final String title;
  bool isFullSize;
  String currentStatus;
  Function()? callback;

  LoaderNew({
    Key? key,
    required this.secondStepLoaderText,
    required this.title,
    this.callback,
    this.isFullSize = false,
    this.currentStatus = 'first-step',
  }) : super(key: key);

  @override
  State<LoaderNew> createState() => _LoaderNewState();
}

class _LoaderNewState extends State<LoaderNew> {
  String firstStepText = 'One second, Jelly is preparing your transaction!';
  String secondStepText = '';
  String thirdStepText = 'Almost done!';
  String currentText = '';
  double loaderImageWidth = 180;
  Timer? timer;

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                isShowNavButton: false,
                title: widget.title,
                action: null,
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  isShowNavButton: false,
                  title: widget.title,
                  action: null,
                  isSmall: true,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        }),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) {
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
    return Container(
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
