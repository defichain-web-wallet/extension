import 'dart:async';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/send/send_status_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/password_bottom_sheet.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendConfirmScreen extends StatefulWidget {
  final String address;
  final String token;
  final double amount;
  final int fee;

  const SendConfirmScreen(this.address, this.token, this.amount, {this.fee = 0});

  @override
  State<SendConfirmScreen> createState() => _SendConfirmState();
}

class _SendConfirmState extends State<SendConfirmScreen> {
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();
  String appBarTitle = 'Send';
  String secondStepLoaderText = 'One second, Jelly is preparing your transaction!';

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
              height: !(txState is TransactionInitialState) ? ToolbarSizes.toolbarHeightWithBottom : ToolbarSizes.toolbarHeight,
              isSmall: isFullScreen,
            ),
            body: BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                return BlocBuilder<TokensCubit, TokensState>(
                  builder: (context, tokensState) {
                    return BlocBuilder<BitcoinCubit, BitcoinState>(
                      builder: (context, bitcoinState) {
                        if (state.status == AccountStatusList.success && tokensState.status == TokensStatusList.success) {
                          return Container(
                            color: Theme.of(context).dialogBackgroundColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 24,
                            ),
                            child: Center(
                              child: StretchBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Do you really want to send',
                                            style: Theme.of(context).textTheme.headline6,
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${balancesHelper.numberStyling(
                                                  widget.amount,
                                                )} ',
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.headline1,
                                              ),
                                            ),
                                            Text(
                                              (widget.token != 'DFI') ? 'd' + widget.token : widget.token,
                                              style: Theme.of(context).textTheme.headline1,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 28),
                                        Text(
                                          'To',
                                          style: Theme.of(context).textTheme.headline6,
                                        ),
                                        SizedBox(height: 28),
                                        Text(
                                          'Address:',
                                          style: Theme.of(context).textTheme.headline6,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          widget.address,
                                          style: Theme.of(context).textTheme.headline2,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: AccentButton(
                                              label: 'Cancel',
                                              callback: () => Navigator.of(context).pop(),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: PendingButton(
                                              'Send',
                                              isCheckLock: false,
                                              callback: (parent) => submit(
                                                state,
                                                tokensState,
                                                isFullScreen,
                                              ),
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

  submit(state, tokensState, isFullScreen) {
    isFullScreen
        ? PasswordBottomSheet.provideWithPasswordFullScreen(context, state.activeAccount, (password) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => LoaderNew(
                  title: appBarTitle,
                  callback: () async {
                    await submitSend(
                      state,
                      tokensState,
                      password,
                    );
                  },
                  secondStepLoaderText: secondStepLoaderText,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          })
        : PasswordBottomSheet.provideWithPassword(context, state.activeAccount, (password) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => LoaderNew(
                  title: appBarTitle,
                  callback: () async {
                    await submitSend(
                      state,
                      tokensState,
                      password,
                    );
                  },
                  secondStepLoaderText: secondStepLoaderText,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          });
  }

  submitSend(state, tokensState, password) async {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    try {
      if (balancesHelper.toSatoshi(widget.amount.toString()) > 0) {
        _callback(state.activeAccount, password, bitcoinCubit, tokensState.tokens);
      }
    } catch (_err) {
      print(_err);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              SendStatusScreen(errorBTC: _err.toString(), appBarTitle: appBarTitle, txResponse: null, amount: widget.amount, token: 'BTC', address: widget.address),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  Future _callback(AccountModel account, String password, BitcoinCubit bitcoinCubit, List<TokensModel> tokens) async {
    ECPair keyPair = await HDWalletService().getKeypairFromStorage(password, account.index!);
    if (SettingsHelper.isBitcoin()) {
      var tx = await transactionService.createBTCTransaction(
        keyPair: keyPair,
        account: account,
        destinationAddress: widget.address,
        amount: balancesHelper.toSatoshi(widget.amount.toString()),
        satPerByte: widget.fee,
      );
      var txResponse = await bitcoinCubit.sendTransaction(tx);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              SendStatusScreen(appBarTitle: appBarTitle, txResponse: txResponse, amount: widget.amount, token: 'BTC', address: widget.address),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      await _sendTransaction(context, tokens, widget.token, account, keyPair);
    }
  }

  Future _sendTransaction(context, List<TokensModel> tokens, String token, AccountModel account, ECPair keyPair) async {
    TxErrorModel? txResponse;
    if (token == 'DFI') {
      txResponse = await transactionService.createAndSendTransaction(
          keyPair: keyPair, account: account, destinationAddress: widget.address, amount: balancesHelper.toSatoshi(widget.amount.toString()), tokens: tokens);
    } else {
      txResponse = await transactionService.createAndSendToken(
          keyPair: keyPair, account: account, token: token, destinationAddress: widget.address, amount: balancesHelper.toSatoshi(widget.amount.toString()), tokens: tokens);
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            SendStatusScreen(appBarTitle: appBarTitle, txResponse: txResponse, amount: widget.amount, token: token, address: widget.address),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
