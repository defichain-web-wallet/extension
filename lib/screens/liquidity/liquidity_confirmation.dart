import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair_details.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_status.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiquidityConfirmation extends StatefulWidget {
  final AssetPairModel assetPair;
  final double baseAmount;
  final double quoteAmount;
  final double amountUSD;
  final double balanceUSD;
  final double shareOfPool;
  final double removeLT;
  final double balanceA;
  final double balanceB;
  final double amount;

  const LiquidityConfirmation(
      {Key? key,
      required this.assetPair,
      required this.baseAmount,
      required this.quoteAmount,
      required this.amountUSD,
      required this.balanceUSD,
      required this.shareOfPool,
      required this.balanceA,
      required this.balanceB,
      required this.amount,
      this.removeLT = 0})
      : super(key: key);

  @override
  State<LiquidityConfirmation> createState() => _LiquidityConfirmationState();
}

class _LiquidityConfirmationState extends State<LiquidityConfirmation> {
  String submitLabel = '';
  TokensHelper tokenHelper = TokensHelper();
  bool isEnable = true;
  bool isPending = false;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                  title: 'Confirmation',
                  isShowBottom: !(state is TransactionInitialState),
                  height: !(state is TransactionInitialState)
                      ? toolbarHeightWithBottom
                      : toolbarHeight),
              body: _buildBody(context, state),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  title: 'Confirmation',
                  action: null,
                  isShowBottom: !(state is TransactionInitialState),
                  height: !(state is TransactionInitialState)
                      ? toolbarHeightWithBottom
                      : toolbarHeight,
                  isSmall: true,
                ),
                body: _buildBody(context, state),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildBody(context, transactionState) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          if (state.status == AccountStatusList.success &&
              tokensState.status == TokensStatusList.success) {
            submitLabel = widget.removeLT == 0 ? 'Add' : 'Remove';
            return Container(
              color: Theme.of(context).dialogBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: StretchBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Text('You will receive',
                                style: Theme.of(context).textTheme.headline6),
                            widget.removeLT == 0
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 28),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${widget.amount.toStringAsFixed(8)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .apply(fontSizeDelta: 12),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8)),
                                        AssetPair(
                                          pair: widget.assetPair.symbol!,
                                        )
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 28),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: SvgPicture.asset(
                                                  tokenHelper
                                                      .getImageNameByTokenName(
                                                          widget.assetPair
                                                              .tokenA),
                                                  height: 25,
                                                  width: 25,
                                                ),
                                              ),
                                              Text(
                                                  '${widget.baseAmount.toStringAsFixed(4)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      ?.apply(fontSizeDelta: 4))
                                            ],
                                          ),
                                        ),
                                        Text(' + ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6
                                                ?.apply(fontSizeDelta: 4)),
                                        Container(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8),
                                                child: SvgPicture.asset(
                                                  tokenHelper
                                                      .getImageNameByTokenName(
                                                          widget.assetPair
                                                              .tokenB),
                                                  height: 25,
                                                  width: 25,
                                                ),
                                              ),
                                              Text(
                                                  '${widget.quoteAmount.toStringAsFixed(4)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6
                                                      ?.apply(fontSizeDelta: 4))
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                            widget.removeLT != 0
                                ? Text(
                                    'exchanging for ${getLiquidityToken()} ${TokensHelper().getTokenFormat(widget.assetPair.symbol)} liquidity tokens',
                                    style:
                                        Theme.of(context).textTheme.headline5)
                                : Column(
                                    children: [
                                      Text(
                                          '${TokensHelper().getTokenFormat(widget.assetPair.symbol)} liquidity tokens',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12)),
                                      Text(
                                          '${widget.shareOfPool.toStringAsFixed(8)}% share of pool',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5)
                                    ],
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(top: 42.0),
                              child: AssetPairDetails(
                                  assetPair: widget.assetPair,
                                  isRemove: widget.removeLT != 0,
                                  amountA: widget.baseAmount,
                                  amountB: widget.quoteAmount,
                                  balanceA: widget.balanceA,
                                  balanceB: widget.balanceB,
                                  totalBalanceInUsd: widget.balanceUSD,
                                  totalAmountInUsd: widget.amountUSD),
                            ),
                            Container(
                                padding: const EdgeInsets.only(top: 24),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: 'Note: ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                      TextSpan(
                                          text:
                                              'Liquidity tokens represent a share of the liquidity pool',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5)
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                child: AccentButton(
                                  label: 'Cancel',
                                  callback: isEnable
                                      ? () => Navigator.of(context).pop()
                                      : null,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                            ),
                            Expanded(
                              child: Container(
                                child: PrimaryButton(
                                    label:
                                        isPending ? 'Pending...' : submitLabel,
                                    isCheckLock: false,
                                    callback: !isPending
                                        ? () {
                                            isEnable = false;
                                            submitLiquidityAction(
                                                state, tokensState, transactionState);
                                          }
                                        : null),
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
  }

  submitLiquidityAction(state, tokensState, transactionState) async {
    if (transactionState is TransactionLoadingState) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Wait for the previous transaction to complete',
            style: Theme.of(context)
                .textTheme
                .headline5,
          ),
          backgroundColor: Theme.of(context)
              .snackBarTheme
              .backgroundColor,
        ),
      );
      return;
    }
    try {
      var txser = TransactionService();
      var txError;
      setState(() {
        isPending = true;
      });
      if (widget.removeLT != 0) {
        txError = await txser.removeLiqudity(
            account: state.activeAccount,
            token: widget.assetPair,
            amount: convertToSatoshi(widget.removeLT));

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => LiquidityStatus(
              assetPair: widget.assetPair,
              isRemove: widget.removeLT != 0,
              amountA: widget.baseAmount,
              amountB: widget.quoteAmount,
              amountUSD: widget.amountUSD,
              balanceUSD: widget.balanceUSD,
              balanceA: widget.balanceA,
              balanceB: widget.balanceB,
              txError: txError,
              isBalanceDetails: false,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        txError = await txser.createAndSendLiqudity(
            account: state.activeAccount,
            tokenA: widget.assetPair.tokenA!,
            tokenB: widget.assetPair.tokenB!,
            amountA: convertToSatoshi(widget.baseAmount),
            amountB: convertToSatoshi(widget.quoteAmount),
            tokens: tokensState.tokens);

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => LiquidityStatus(
              assetPair: widget.assetPair,
              isRemove: widget.removeLT != 0,
              amountA: widget.baseAmount,
              amountB: widget.quoteAmount,
              amountUSD: widget.amountUSD,
              balanceUSD: widget.balanceUSD,
              balanceA: widget.balanceA,
              balanceB: widget.balanceB,
              txError: txError,
              isBalanceDetails: false,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
      setState(() {
        isPending = false;
      });
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong. Please, try later',
            style: Theme.of(context)
                .textTheme
                .headline5,
          ),
          backgroundColor: Theme.of(context)
              .snackBarTheme
              .backgroundColor,
        ),
      );
      setState(() {
        isPending = false;
      });
    }
  }

  String getLiquidityToken() {
    if (widget.removeLT != 0) {
      return widget.removeLT.toStringAsFixed(8);
    } else {
      return '${widget.baseAmount.toString()}-${widget.quoteAmount.toString()}';
    }
  }
}
