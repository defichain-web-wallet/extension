import 'dart:async';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/ledger/ledger_confirm_send.dart';
import 'package:defi_wallet/screens/send/send_status/send_status.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendConfirmScreen extends StatefulWidget {
  final String address;
  final String token;
  final double amount;

  const SendConfirmScreen(this.address, this.token, this.amount);

  @override
  State<SendConfirmScreen> createState() => _SendConfirmState();
}

class _SendConfirmState extends State<SendConfirmScreen> {
  BalancesHelper balancesHelper = BalancesHelper();
  TransactionService transactionService = TransactionService();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  bool isEnable = true;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) => ScaffoldConstrainedBox(
            child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                  title: 'Send',
                  isShowBottom: !(state is TransactionInitialState),
                  height: !(state is TransactionInitialState)
                      ? toolbarHeightWithBottom
                      : toolbarHeight),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  title: 'Send',
                  action: null,
                  isShowBottom: !(state is TransactionInitialState),
                  height: !(state is TransactionInitialState)
                      ? toolbarHeightWithBottom
                      : toolbarHeight,
                  isSmall: true,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        })),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) =>
      BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
        return BlocBuilder<TokensCubit, TokensState>(
          builder: (context, tokensState) {
            if (state.status == AccountStatusList.success &&
                tokensState.status == TokensStatusList.success) {
              return Container(
                color: isCustomBgColor
                    ? Theme.of(context).dialogBackgroundColor
                    : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                                    '${balancesHelper.numberStyling(widget.amount)} ',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                  ),
                                ),
                                Text(
                                  (widget.token != 'DFI')
                                      ? 'd' + widget.token
                                      : widget.token,
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
                                  callback: isEnable
                                      ? () => Navigator.of(context).pop()
                                      : null,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: PendingButton(
                                  'Send',
                                  isCheckLock: false,
                                  callback: (parent) {
                                    setState(() {
                                      isEnable = false;
                                    });
                                    submitSend(parent, state, tokensState);
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
      });

  submitSend(parent, state, tokensState) async {
    parent.emitPending(true);

    try {
      if (balancesHelper.toSatoshi(widget.amount.toString()) > 0) {
        await _sendTransaction(
            context, tokensState, widget.token, state.activeAccount);
      }
    } catch (_) {
      print(_);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Some error. Please try later',
              style: Theme.of(context).textTheme.headline5),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
    }

    parent.emitPending(false);
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
