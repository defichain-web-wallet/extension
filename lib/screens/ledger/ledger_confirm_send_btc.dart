import 'dart:developer';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/screens/home/widgets/home_app_bar.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LedgerConfirmSendBtc extends StatefulWidget {
  const LedgerConfirmSendBtc({Key? key}) : super(key: key);

  @override
  State<LedgerConfirmSendBtc> createState() => _LedgerConfirmSendBtcState();
}

class _LedgerConfirmSendBtcState extends State<LedgerConfirmSendBtc> {
  LockHelper lockHelper = LockHelper();
  GlobalKey<AccountSelectState> _selectKey = GlobalKey<AccountSelectState>();
  bool isChange = true;
  String confirmLegerText =
      'Please confirm the process on your device to complete it.';
  String sendingBtcText = 'Sending BTC';
  String receivingAddressText = 'Receiving address';
  String feesText = 'Fees';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (BuildContext context, state) {
        if (state.status == AccountStatusList.success) {
          return ScaffoldConstrainedBox(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: HomeAppBar(
                      isRefresh: false,
                      isSettingsList: false,
                      selectKey: _selectKey,
                      updateCallback: () =>
                          updateAccountDetails(context, state),
                      hideOverlay: () => hideOverlay(),
                    ),
                    body: _buildBody(state),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: HomeAppBar(
                        isRefresh: false,
                        isSettingsList: false,
                        isSmall: false,
                        selectKey: _selectKey,
                        updateCallback: () =>
                            updateAccountDetails(context, state),
                        hideOverlay: () => hideOverlay(),
                      ),
                      body: _buildBody(state, isFullSize: true),
                    ),
                  );
                }
              },
            ),
          );
        } else
          return Container();
      },
    );
  }

  Widget _buildBody(state, {isFullSize = false}) => Container(
        color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
        padding:
            const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
        child: Center(
          child: StretchBox(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 30,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    confirmLegerText,
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: isFullSize
                                        ? Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .apply(fontSizeFactor: 1.2)
                                        : Theme.of(context).textTheme.headline5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sendingBtcText,
                                        style: isFullSize
                                            ? Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .apply(fontSizeFactor: 1.2)
                                            : Theme.of(context)
                                                .textTheme
                                                .headline5,
                                      ),
                                      Text(
                                        'Account 2 - Bitcoin Network',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '0.0000013 DFI',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        '≈  0,01 USD',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        receivingAddressText,
                                        style: isFullSize
                                            ? Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .apply(fontSizeFactor: 1.2)
                                            : Theme.of(context)
                                                .textTheme
                                                .headline5,
                                      ),
                                      Text(
                                        'Contact available? User account?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        cutAddress(
                                            'df1qd5a34pm8nd6d6yh87npf4ze6fsuu4v5lkamzhl'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        feesText,
                                        style: isFullSize
                                            ? Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .apply(fontSizeFactor: 1.2)
                                            : Theme.of(context)
                                                .textTheme
                                                .headline5,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '0.0000013 DFI',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2,
                                      ),
                                      Text(
                                        '≈  0,01 USD',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              SettingsHelper.settings.theme == 'Light'
                                  ? 'assets/images/ledger_light_selected.png'
                                  : 'assets/images/ledger_dark_selected.png',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  updateAccountDetails(context, state) async {
    lockHelper.provideWithLockChecker(context, () async {
      hideOverlay();
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      if (state.status == AccountStatusList.success) {
        await accountCubit.updateAccountDetails();

        Future.delayed(const Duration(milliseconds: 1), () async {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  LedgerConfirmSendBtc(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        });
      }
    });
  }

  void hideOverlay() {
    try {
      _selectKey.currentState!.hideOverlay();
    } catch (err) {
      log('error when try to hide overlay: $err');
    }
  }

  String cutAddress(String s) {
    return s.substring(0, 4) + '...' + s.substring(38, 42);
  }
}
