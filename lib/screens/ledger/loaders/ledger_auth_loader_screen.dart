import 'dart:async';
import 'dart:convert';
import 'dart:js_util';
import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_ledger_network_model.dart';
import 'package:defi_wallet/models/network/ledger_account_model.dart';
import 'package:defi_wallet/screens/ledger/ledger_error_dialog.dart';
import 'package:defi_wallet/services/bitcoin_service.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class LedgerAuthLoaderScreen extends StatefulWidget {
  final bool isFullSize;
  final Function() callback;
  final Function(Object error) errorCallback;
  String currentStatus;

  final String appName;

  LedgerAuthLoaderScreen(
      {Key? key,
      required this.callback,
      required this.errorCallback,
      required this.appName,
      this.isFullSize = true,
      this.currentStatus = 'first-step'})
      : super(key: key);

  @override
  State<LedgerAuthLoaderScreen> createState() => _LedgerAuthLoaderScreenState();
}

class _LedgerAuthLoaderScreenState extends State<LedgerAuthLoaderScreen>
    with ThemeMixin {
  String firstStepText = 'One second, Jelly is searching for your addresses...';
  String secondStepText = 'Ugh.. What a mess...';
  String thirdStepText = 'Okay, almost done...';
  String currentText = '';

  // String currentStatus = 'first-step';
  double loaderImageWidth = 54;

  void initState() {
    super.initState();
  }

  Future init() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.walletType, "ledger");
    await box.close();

    jellyLedgerInit();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStatus == 'first-step') {
      currentText = firstStepText;
    }
    if (widget.currentStatus == 'first-step') {
      Future.delayed(const Duration(milliseconds: 10), () async {
        await restoreWallet();
      });
    }
    return Container(
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
                    height: 153,
                    child: Text(
                      currentText,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.6),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future restoreWallet() async {
    await init();
    try {
      WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

      String path;

      bool isTestnet = this.widget.appName == "test";
      var index = walletCubit.state.accounts
          .where((element) =>
              element is LedgerAccountModel &&
              element.appName == this.widget.appName &&
              element.isTestnet == isTestnet)
          .length;
      if (this.widget.appName == "dfi") {
        path = HDWalletService.derivePath(index);
      } else {
        path = new BitcoinService().deriveLedgerPath(index, isTestnet);
      }

      var ledgerAddressJson = await promiseToFuture<dynamic>(
          getAddress(this.widget.appName, path, false));
      var ledgerAddress = jsonDecode(ledgerAddressJson);
      var pubKey = ledgerAddress["publicKey"];
      var address = ledgerAddress["bitcoinAddress"];

      if (pubKey == null || address == null || pubKey == "" || address == "") {
        throw new Exception("no address generated..");
      }
      await walletCubit.addNewLedgerAccount(
          "Ledger ${this.widget.appName} (${index + 1})",
          address,
          pubKey,
          path,
          isTestnet,
          this.widget.appName);

      widget.callback();
    } on Exception catch (error) {
      print(error);
      await showDialog(
        barrierColor: AppColors.tolopea.withOpacity(0.06),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return LedgerErrorDialog(error: error);
        },
      );
      widget.errorCallback(error);
    } catch (er) {
      await showDialog(
        barrierColor: AppColors.tolopea.withOpacity(0.06),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dialogContext) {
          return LedgerErrorDialog(error: er);
        },
      );
      widget.errorCallback(er);
    }
  }

  getStatusText(String currentStatus, int need, int restored) async {
    print(need);
    print(restored);
    print(currentStatus);
    if (currentStatus == 'first-step' && restored >= 3) {
      setState(() {
        widget.currentStatus = 'second-step';
        currentText = secondStepText;
      });
    }
    if (currentStatus == 'second-step' && restored >= 6) {
      setState(() {
        widget.currentStatus = 'third-step';
        currentText = thirdStepText;
      });
    }
    if (currentStatus == 'third-step' && need == restored) {
      widget.callback();
    }
  }
}
