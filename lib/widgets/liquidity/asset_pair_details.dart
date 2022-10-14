import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssetPairDetails extends StatefulWidget {
  final AssetPairModel assetPair;
  final bool isRemove;
  final double amountA;
  final double amountB;
  final double balanceA;
  final double balanceB;
  final double totalBalanceInUsd;
  final double totalAmountInUsd;
  final bool isBalanceDetails;

  const AssetPairDetails({
    Key? key,
    required this.assetPair,
    required this.isRemove,
    required this.amountA,
    required this.totalBalanceInUsd,
    required this.totalAmountInUsd,
    required this.amountB,
    required this.balanceA,
    required this.balanceB,
    this.isBalanceDetails = true,
  }) : super(key: key);

  @override
  _AssetPairDetailsState createState() => _AssetPairDetailsState();
}

class _AssetPairDetailsState extends State<AssetPairDetails> {
  int iterator = 0;
  double balanceA = 0;
  double balanceB = 0;
  double balanceUsd = 0;
  double targetAmountUsd = 0;

  @override
  Widget build(BuildContext context) {
    String fiat = SettingsHelper.settings.currency!;
    TokensHelper tokensHelper = TokensHelper();

    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, tokensState) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.status == AccountStatusList.success &&
                tokensState.status == TokensStatusList.success) {
              if (iterator == 0) {
                var baseBalance = List.from(state.activeAccount!.balanceList!
                    .where((element) =>
                        element.token == widget.assetPair.tokenA))[0];
                var quoteBalance = List.from(state.activeAccount!.balanceList!
                    .where((element) =>
                        element.token == widget.assetPair.tokenB))[0];

                balanceA = convertFromSatoshi(baseBalance.balance!);
                balanceB = convertFromSatoshi(quoteBalance.balance!);

                balanceUsd += tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.balanceA,
                  widget.assetPair.tokenA!,
                );
                balanceUsd += tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.balanceB,
                  widget.assetPair.tokenB!,
                );
                targetAmountUsd += tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.amountA,
                  widget.assetPair.tokenA!,
                );
                targetAmountUsd += tokensHelper.getAmountByUsd(
                  tokensState.tokensPairs!,
                  widget.amountB,
                  widget.assetPair.tokenB!,
                );

                iterator++;
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                AssetPair(
                                  pair: widget.assetPair.symbol!,
                                  size: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                      TokensHelper().getTokenFormat(
                                          widget.assetPair.symbol!),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.apply(fontSizeDelta: 2)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Text(
                                TokensHelper()
                                    .getAprFormat(widget.assetPair.apr!),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.apply(fontSizeDelta: 2)),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 22),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pooled ${widget.assetPair.tokenA}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.apply(fontWeightDelta: 2)),
                                RichText(
                                    text: TextSpan(children: [
                                  if (widget.isBalanceDetails)
                                    TextSpan(
                                      text:
                                          '${widget.balanceA.toStringAsFixed(8)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.apply(
                                              fontWeightDelta: 2,
                                              fontSizeDelta: 3),
                                    ),
                                  getFormatAmountText(
                                      widget.amountA.toStringAsFixed(8)),
                                ]))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pooled ${widget.assetPair.tokenB}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.apply(fontWeightDelta: 2)),
                                RichText(
                                    text: TextSpan(children: [
                                  if (widget.isBalanceDetails)
                                    TextSpan(
                                      text:
                                          '${widget.balanceB.toStringAsFixed(8)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.apply(
                                              fontWeightDelta: 2,
                                              fontSizeDelta: 3),
                                    ),
                                  getFormatAmountText(
                                      widget.amountB.toStringAsFixed(8)),
                                ]))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pooled $fiat',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5
                                        ?.apply(fontWeightDelta: 2)),
                                RichText(
                                    text: TextSpan(children: [
                                  if (widget.isBalanceDetails)
                                    TextSpan(
                                      text: getPooledByFiatFormat(balanceUsd,
                                          fiat, tokensState.eurRate),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.apply(
                                              fontWeightDelta: 2,
                                              fontSizeDelta: 3),
                                    ),
                                  getFormatAmountText(getPooledByFiatFormat(
                                      targetAmountUsd,
                                      fiat,
                                      tokensState.eurRate)),
                                ]))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  String getPooledByFiatFormat(amount, fiat, eurRate) {
    if (fiat == 'EUR') {
      return (amount * eurRate).toStringAsFixed(2);
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  TextSpan getFormatAmountText(stringAmount) {
    if (widget.isBalanceDetails) {
      return TextSpan(
        text: ' ${widget.isRemove ? '-' : '+'}$stringAmount',
        style: Theme.of(context)
            .textTheme
            .headline4
            ?.apply(color: Colors.grey, fontWeightDelta: 2, fontSizeDelta: 3),
      );
    } else {
      return TextSpan(
        text: '$stringAmount',
        style: Theme.of(context)
            .textTheme
            .headline4
            ?.apply(fontWeightDelta: 2, fontSizeDelta: 3),
      );
    }
  }
}
