import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/dex/swap_status.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/widgets/loader/loader_new.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LedgerConfirmSwap extends StatefulWidget {
  final String assetFrom;
  final String assetTo;
  final double amountFrom;
  final double amountTo;
  final double slippage;
  final String btcTx;

  const LedgerConfirmSwap(this.assetFrom, this.assetTo, this.amountFrom,
      this.amountTo, this.slippage,
      {this.btcTx = ''});

  @override
  State<LedgerConfirmSwap> createState() => _LedgerConfirmSwapState();
}

class _LedgerConfirmSwapState extends State<LedgerConfirmSwap> {
  LockHelper lockHelper = LockHelper();
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokensHelper = TokensHelper();
  TransactionService transactionService = TransactionService();
  String confirmLegerText =
      'Please confirm the process on your device to complete it.';
  String swapFromText = 'Swap from';
  String swapToText = 'Swap to';
  String feesText = 'Fees';
  late String amountToFormat;
  late String amountFromFormat;
  late String amountToFormatByUsd;
  late String amountFromFormatByUsd;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(builder:
        (BuildContext context, bool isFullScreen, TransactionState txState) {
      return Scaffold(
        appBar: MainAppBar(
          title: 'Swap',
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
                double amountToUsd = tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.amountTo,
                  widget.assetTo,
                );
                double amountFromUsd = tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.amountFrom,
                  widget.assetFrom,
                );
                amountToFormat = balancesHelper.numberStyling(
                  widget.amountTo,
                  fixed: true,
                  fixedCount: 6,
                );
                amountFromFormat = balancesHelper.numberStyling(
                  widget.amountFrom,
                  fixed: true,
                  fixedCount: 6,
                );
                amountToFormatByUsd = balancesHelper.numberStyling(
                  amountToUsd,
                  fixed: true,
                  fixedCount: 2,
                );
                amountFromFormatByUsd = balancesHelper.numberStyling(
                  amountFromUsd,
                  fixed: true,
                  fixedCount: 2,
                );
                submitSwap(accountState, tokensState);
                return Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  padding:
                  const EdgeInsets.only(top: 24, bottom: 24),
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
                                    vertical: 20,
                                    horizontal: 30,
                                  ),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
                                              style: isFullScreen
                                                  ? Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .apply(fontSizeFactor: 1.2)
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  swapFromText,
                                                  style: isFullScreen
                                                      ? Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .apply(fontSizeFactor: 1.2)
                                                      : Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                                ),
                                                Text(
                                                  'Account 1 - Defichain Network',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2,
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
                                                  '$amountFromFormat ${widget.assetFrom}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                                Text(
                                                  '≈  $amountFromFormatByUsd USD',
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
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  swapToText,
                                                  style: isFullScreen
                                                      ? Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .apply(fontSizeFactor: 1.2)
                                                      : Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                                ),
                                                Text(
                                                  'Account 1 - Defichain Network',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2,
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
                                                  '$amountToFormat ${widget.assetTo}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline2,
                                                ),
                                                Text(
                                                  '≈  $amountToFormatByUsd USD',
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
          }
        ),
      );
    });
  }

  submitSwap(
      state,
      tokenState,
      ) async {
    if (state.status == AccountStatusList.success) {
      try {
        if (widget.btcTx != '') {
          BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
          var txResponse = await bitcoinCubit.sendTransaction(widget.btcTx);
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    SwapStatusScreen(
                        appBarTitle: 'Swap',
                        txResponse: txResponse,
                        amount: widget.amountFrom,
                        assetFrom: widget.assetFrom,
                        assetTo: widget.assetTo),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ));
        }
        if (widget.assetFrom != widget.assetTo) {
          var txResponse = await transactionService.createAndSendSwap(
              account: state.activeAccount,
              tokenFrom: widget.assetFrom,
              tokenTo: widget.assetTo,
              amount: balancesHelper.toSatoshi(widget.amountFrom.toString()),
              amountTo: balancesHelper.toSatoshi(widget.amountTo.toString()),
              slippage: widget.slippage,
              tokens: tokenState.tokens);
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
                      pageBuilder: (context, animation1, animation2) =>
                          SwapStatusScreen(
                              appBarTitle: 'Swap',
                              txResponse: txResponse,
                              amount: widget.amountFrom,
                              assetFrom: widget.assetFrom,
                              assetTo: widget.assetTo),
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
      } catch (err) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SwapStatusScreen(
                      appBarTitle: 'Swap',
                      txResponse: TxErrorModel(isError: true, error: err.toString()),
                      amount: widget.amountFrom,
                      assetFrom: widget.assetFrom,
                      assetTo: widget.assetTo),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      }
    }
  }
}
