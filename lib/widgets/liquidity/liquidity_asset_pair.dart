import 'dart:ui';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiquidityAssetPair extends StatefulWidget {
  final AssetPairModel? assetPair;
  final int? balance;

  const LiquidityAssetPair({Key? key, this.assetPair, this.balance})
      : super(key: key);

  @override
  State<LiquidityAssetPair> createState() => _LiquidityAssetPairState();
}

class _LiquidityAssetPairState extends State<LiquidityAssetPair> with ThemeMixin{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pooled ${widget.assetPair!.tokenA}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .headline5!
                    .color!
                    .withOpacity(0.5),
              ),
            ),
            Text(
              '${getBaseBalance(widget.balance, widget.assetPair!)}',
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 12,
        ),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pooled ${widget.assetPair!.tokenB}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(
                fontSize: 12,
                color: Theme.of(context)
                    .textTheme
                    .headline5!
                    .color!
                    .withOpacity(0.5),
              ),
            ),
            Text(
              '${getQuoteBalance(widget.balance, widget.assetPair!)}',
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String getBaseBalance(balance, assetPair) {
    List<double> result =
    BalancesHelper().calculateAmountFromLiqudity(widget.balance!, widget.assetPair!);
    return toFixed(result[0], 4);
  }

  String getQuoteBalance(balance, assetPair) {
    List<double> result =
    BalancesHelper().calculateAmountFromLiqudity(widget.balance!, widget.assetPair!);
    return toFixed(result[1], 4);
  }
}
