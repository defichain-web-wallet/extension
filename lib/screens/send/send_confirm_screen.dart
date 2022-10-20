import 'dart:async';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/send/send_status_screen.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendConfirmScreen extends StatefulWidget {
  final String address;
  final String token;
  final double amount;
  final int fee;

  const SendConfirmScreen(this.address, this.token, this.amount,
      {this.fee = 0});

  @override
  State<SendConfirmScreen> createState() => _SendConfirmState();
}

class _SendConfirmState extends State<SendConfirmScreen> {
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  String appBarTitle = 'Send';
  String secondStepLoaderText =
      'One second, Jelly is preparing your transaction!';

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
        builder: (
          BuildContext context,
          bool isFullScreen,
          TransactionState txState,
        ) {
          return Scaffold(
            appBar: MainAppBar(
              title: appBarTitle,
              isShowBottom: !(txState is TransactionInitialState),
              height: !(txState is TransactionInitialState)
                  ? toolbarHeightWithBottom
                  : toolbarHeight,
              isSmall: isFullScreen,
            ),
            body: BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                return BlocBuilder<TokensCubit, TokensState>(
                  builder: (context, tokensState) {
                    return BlocBuilder<BitcoinCubit, BitcoinState>(
                      builder: (context, bitcoinState) {
                        if (state.status == AccountStatusList.success &&
                            tokensState.status == TokensStatusList.success) {
                          return Container(
                            color: Theme.of(context).dialogBackgroundColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            child: Center(
                              child: StretchBox(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Do you really want to send',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${balancesHelper.numberStyling(
                                                  widget.amount,
                                                )} ',
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline1,
                                              ),
                                            ),
                                            Text(
                                              (widget.token != 'DFI')
                                                  ? 'd' + widget.token
                                                  : widget.token,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline1,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 28),
                                        Text(
                                          'To',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                        SizedBox(height: 28),
                                        Text(
                                          'Address:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          widget.address,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline2,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: AccentButton(
                                              label: 'Cancel',
                                              callback: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: PendingButton(
                                              'Send',
                                              isCheckLock: false,
                                              callback: (parent) {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        LoaderNew(
                                                      title: appBarTitle,
                                                      callback: () async {
                                                        await submitSend(
                                                            state, tokensState);
                                                      },
                                                      secondStepLoaderText:
                                                          secondStepLoaderText,
                                                    ),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              },
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
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      );

  submitSend(state, tokensState) async {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    try {
      if (balancesHelper.toSatoshi(widget.amount.toString()) > 0) {
        if (SettingsHelper.isBitcoin()) {
          var tx = await transactionService.createBTCTransaction(
            account: state.activeAccount,
            destinationAddress: widget.address,
            amount: balancesHelper.toSatoshi(widget.amount.toString()),
            satPerByte: widget.fee,
          );
          var txResponse = await bitcoinCubit.sendTransaction(tx);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SendStatusScreen(
                      appBarTitle: appBarTitle,
                      txResponse: txResponse,
                      amount: widget.amount,
                      token: 'BTC',
                      address: widget.address),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          await _sendTransaction(
              context, tokensState, widget.token, state.activeAccount);
        }
      }
    } catch (_err) {
      print(_err);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SendStatusScreen(
              errorBTC: _err.toString(),
              appBarTitle: appBarTitle,
              txResponse: null,
              amount: widget.amount,
              token: 'BTC',
              address: widget.address),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
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
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => SendStatusScreen(
            appBarTitle: appBarTitle,
            txResponse: txResponse,
            amount: widget.amount,
            token: token,
            address: widget.address),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
