import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/send/send_status_screen.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LedgerConfirmSend extends StatefulWidget {
  final String address;
  final String token;
  final double amount;
  final int fee;

  const LedgerConfirmSend(this.address, this.token, this.amount,
      {this.fee = 0});

  @override
  State<LedgerConfirmSend> createState() => _LedgerConfirmSendState();
}

class _LedgerConfirmSendState extends State<LedgerConfirmSend> {
  LockHelper lockHelper = LockHelper();
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokensHelper = TokensHelper();
  TransactionService transactionService = TransactionService();
  bool isChange = true;
  String confirmLegerText =
      'Please confirm the process on your device to complete it.';
  String amountText = 'Amount';
  String feesText = 'Fees';
  late String amountFormat;
  late String amountFormatByUsd;
  late String feeFormat;
  late String feeFormatByUsd;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder:
          (BuildContext context, bool isFullScreen, TransactionState txState) {
        return Scaffold(
          appBar: MainAppBar(
            title: 'Send',
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: BlocBuilder<AccountCubit, AccountState>(
              builder: (context, accountState) {
            return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) {
                double amountByUsd = tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.amount,
                  widget.token,
                );
                double feeByUsd = tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.fee * .0,
                  widget.token,
                );
                amountFormat = balancesHelper.numberStyling(
                  widget.amount,
                  fixed: true,
                  fixedCount: 6,
                );
                amountFormatByUsd = balancesHelper.numberStyling(
                  amountByUsd,
                  fixed: true,
                  fixedCount: 6,
                );
                feeFormat = balancesHelper.numberStyling(
                  widget.fee * .0,
                  fixed: true,
                  fixedCount: 6,
                );
                feeFormatByUsd = balancesHelper.numberStyling(
                  feeByUsd,
                  fixedCount: 2,
                  fixed: true,
                );
                _sendTransaction(
                  context,
                  tokensState,
                  widget.token,
                  accountState.activeAccount!,
                );
                return Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 12,
                                  ),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              confirmLegerText,
                                              textAlign: TextAlign.center,
                                              softWrap: true,
                                              style: isFullScreen
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .apply(
                                                          fontSizeFactor: 1.2)
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  amountText,
                                                  style: isFullScreen
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .headline5!
                                                          .apply(
                                                              fontSizeFactor:
                                                                  1.2)
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$amountFormat ${widget.token}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                                Text(
                                                  '≈ $amountFormatByUsd USD',
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  feesText,
                                                  style: isFullScreen
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .headline5!
                                                          .apply(
                                                              fontSizeFactor:
                                                                  1.2)
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${widget.fee} ${widget.token}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                                Text(
                                                  '≈  $feeFormatByUsd USD',
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
              },
            );
          }),
        );
      },
    );
  }

  Future _sendTransaction(
      context, tokensState, String token, AccountModel account) async {
    TxErrorModel? txResponse;
    if (token == 'DFI') {
      txResponse = await transactionService.createAndSendTransaction(
          account: account,
          destinationAddress: widget.address,
          amount: balancesHelper.toSatoshi(widget.amount.toString()),
          tokens: tokensState.tokens);
    } else {
      txResponse = await transactionService.createAndSendToken(
          account: account,
          token: token,
          destinationAddress: widget.address,
          amount: balancesHelper.toSatoshi(widget.amount.toString()),
          tokens: tokensState.tokens);
    }
    String secondStepLoaderText =
        'One second, Jelly is preparing your transaction!';
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LoaderNew(
          title: 'Send',
          secondStepLoaderText: secondStepLoaderText,
          callback: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => SendStatusScreen(
                    appBarTitle: 'Send',
                    txResponse: txResponse,
                    amount: widget.amount,
                    token: token,
                    address: widget.address),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
