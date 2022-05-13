import 'dart:ui';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiquidityAssetPair extends StatelessWidget {
  final AssetPairModel? assetPair;
  final int? balance;

  const LiquidityAssetPair({Key? key, this.assetPair, this.balance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TokensHelper tokenHelper = TokensHelper();

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 2)),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  tokenHelper.getImageNameByTokenName(assetPair!.tokenA),
                  height: 15,
                  width: 15,
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 2)),
                Text(getBaseBalance(balance, assetPair!), style: TextStyle(
                  fontFeatures: [
                    FontFeature.tabularFigures()
                  ],
                ))
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 2)),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  tokenHelper.getImageNameByTokenName(assetPair!.tokenB),
                  height: 15,
                  width: 15,
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 2)),
                Text(getQuoteBalance(balance, assetPair!), style: TextStyle(
                  fontFeatures: [
                    FontFeature.tabularFigures()
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getBaseBalance(balance, assetPair) {
    double result =
        balance * (1 / assetPair!.totalLiquidityRaw) * assetPair.reserveA!;
    return toFixed(result, 4);
  }

  String getQuoteBalance(balance, assetPair) {
    double result =
        balance * (1 / assetPair!.totalLiquidityRaw) * assetPair.reserveB!;
    return toFixed(result, 4);
  }
}
