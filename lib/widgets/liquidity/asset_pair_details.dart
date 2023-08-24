import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class AssetPairDetails extends StatefulWidget {
  final LmPoolModel assetPair;
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

    // if (iterator == 0) {
    //   balanceUsd += tokensHelper.getAmountByUsd(
    //     tokensState.tokensPairs!,
    //     widget.balanceA,
    //     widget.assetPair.tokens,
    //   );
    //   balanceUsd += tokensHelper.getAmountByUsd(
    //     tokensState.tokensPairs!,
    //     widget.balanceB,
    //     widget.assetPair.tokenB!,
    //   );
    //   targetAmountUsd += tokensHelper.getAmountByUsd(
    //     tokensState.tokensPairs!,
    //     widget.amountA,
    //     widget.assetPair.tokenA!,
    //   );
    //   targetAmountUsd += tokensHelper.getAmountByUsd(
    //     tokensState.tokensPairs!,
    //     widget.amountB,
    //     widget.assetPair.tokenB!,
    //   );
    //
    //   iterator++;
    // }
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pooled ${widget.assetPair.tokens[0].displaySymbol}',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .headline5!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${widget.balanceA.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    if (!widget.isRemove)
                      TextSpan(
                        text: getFormatAmountText(
                          widget.amountA.toStringAsFixed(6),
                        ),
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .color!
                                  .withOpacity(0.3),
                            ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.lavenderPurple.withOpacity(0.16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pooled ${widget.assetPair.tokens[0].displaySymbol}',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .headline5!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '${widget.balanceB.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    if (!widget.isRemove)
                      TextSpan(
                        text: getFormatAmountText(
                          widget.amountB.toStringAsFixed(6),
                        ),
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .color!
                                  .withOpacity(0.3),
                            ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.lavenderPurple.withOpacity(0.16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pooled $fiat',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .headline5!
                            .color!
                            .withOpacity(0.3),
                      ),
                ),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: '0',
                      // getPooledByFiatFormat(
                      //   balanceUsd,
                      //   fiat,
                      //   tokensState.eurRate,
                      // ),
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    if (!widget.isRemove)
                      TextSpan(
                        text: '0',
                        // getFormatAmountText(
                        //   getPooledByFiatFormat(targetAmountUsd, fiat,
                        //       tokensState.eurRate),
                        // ),
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .color!
                                  .withOpacity(0.3),
                            ),
                      ),
                  ]),
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.only(top: 22),
          //   child: Column(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 4.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text('Pooled ${widget.assetPair.tokenA}',
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .headline5
          //                     ?.apply(fontWeightDelta: 2)),
          //             RichText(
          //                 text: TextSpan(children: [
          //               if (widget.isBalanceDetails)
          //                 TextSpan(
          //                   text:
          //                       '${widget.balanceA.toStringAsFixed(8)}',
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .headline4
          //                       ?.apply(
          //                           fontWeightDelta: 2,
          //                           fontSizeDelta: 3),
          //                 ),
          //               getFormatAmountText(
          //                   widget.amountA.toStringAsFixed(8)),
          //             ]))
          //           ],
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 4.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text('Pooled ${widget.assetPair.tokenB}',
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .headline5
          //                     ?.apply(fontWeightDelta: 2)),
          //             RichText(
          //                 text: TextSpan(children: [
          //               if (widget.isBalanceDetails)
          //                 TextSpan(
          //                   text:
          //                       '${widget.balanceB.toStringAsFixed(8)}',
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .headline4
          //                       ?.apply(
          //                           fontWeightDelta: 2,
          //                           fontSizeDelta: 3),
          //                 ),
          //               getFormatAmountText(
          //                   widget.amountB.toStringAsFixed(8)),
          //             ]))
          //           ],
          //         ),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 4.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text('Pooled $fiat',
          //                 style: Theme.of(context)
          //                     .textTheme
          //                     .headline5
          //                     ?.apply(fontWeightDelta: 2)),
          //             RichText(
          //                 text: TextSpan(children: [
          //               if (widget.isBalanceDetails)
          //                 TextSpan(
          //                   text: getPooledByFiatFormat(balanceUsd,
          //                       fiat, tokensState.eurRate),
          //                   style: Theme.of(context)
          //                       .textTheme
          //                       .headline4
          //                       ?.apply(
          //                           fontWeightDelta: 2,
          //                           fontSizeDelta: 3),
          //                 ),
          //               getFormatAmountText(getPooledByFiatFormat(
          //                   targetAmountUsd,
          //                   fiat,
          //                   tokensState.eurRate)),
          //             ]))
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  String getPooledByFiatFormat(amount, fiat, eurRate) {
    if (fiat == 'EUR') {
      return (amount * eurRate).toStringAsFixed(2);
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  String getFormatAmountText(stringAmount) {
    if (widget.isBalanceDetails) {
      return ' ${widget.isRemove ? '-' : '+'}$stringAmount';
    } else {
      return '$stringAmount';
    }
  }
}
