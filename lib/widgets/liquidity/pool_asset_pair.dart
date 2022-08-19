import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PoolAssetPair extends StatefulWidget {
  final AssetPairModel assetPair;
  final bool isFullSize;

  const PoolAssetPair(
      {Key? key, required this.assetPair, this.isFullSize = false})
      : super(key: key);

  @override
  _PoolAssetPairState createState() => _PoolAssetPairState();
}

class _PoolAssetPairState extends State<PoolAssetPair> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 22,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
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
                          isTransform: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Container(
                            width: widget.isFullSize ? 123 : 73,
                            child: TickerText(
                              child: Text(
                                  TokensHelper()
                                      .getTokenFormat(widget.assetPair.symbol!),
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.isFullSize
                                      ? Theme.of(context).textTheme.headline6
                                      : Theme.of(context)
                                          .textTheme
                                          .headline4
                                          ?.apply(fontWeightDelta: 2)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Yield',
                            style: widget.isFullSize
                                ? Theme.of(context)
                                    .textTheme
                                    .headline5
                                    ?.apply(fontWeightDelta: 2)
                                : Theme.of(context)
                                    .textTheme
                                    .headline4
                                    ?.apply(fontWeightDelta: 2)),
                        Text(
                            TokensHelper().getAprFormat(widget.assetPair.apr!),
                            style: Theme.of(context).textTheme.headline4)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: widget.isFullSize
                                ? Theme.of(context)
                                    .textTheme
                                    .headline5
                                    ?.apply(fontWeightDelta: 2)
                                : Theme.of(context)
                                    .textTheme
                                    .headline4
                                    ?.apply(fontWeightDelta: 2)),
                        Text(
                            getTotalAmountByUsd(
                                widget.assetPair.totalLiquidityUsd!),
                            style: Theme.of(context).textTheme.headline4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTotalAmountByUsd(double amount) {
    BalancesHelper balancesHelper = BalancesHelper();

    String amountFormat =
        balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
    return '$amountFormat\$';
  }
}
