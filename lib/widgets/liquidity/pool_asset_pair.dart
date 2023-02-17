import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PoolAssetPair extends StatefulWidget {
  final AssetPairModel assetPair;
  final bool isGrid;

  const PoolAssetPair({Key? key, required this.assetPair, this.isGrid = true})
      : super(key: key);

  @override
  _PoolAssetPairState createState() => _PoolAssetPairState();
}

class _PoolAssetPairState extends State<PoolAssetPair> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.isGrid) {
      return Container(
        width: 160,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.8),
            border: Border.all(
              color: isDarkTheme()
                  ? DarkColors.assetItemSelectorBorderColor.withOpacity(0.16)
                  : LightColors.assetItemSelectorBorderColor.withOpacity(0.16),
            )),
        child: Container(
          decoration: BoxDecoration(
            // color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AssetPair(
                pair: widget.assetPair.symbol!,
                isTransform: false,
              ),
              SizedBox(
                height: 8,
              ),
              TickerText(
                child: Text(
                  '${widget.assetPair.symbol!}',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                '${widget.assetPair.symbol!}',
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      fontSize: 11,
                      color: Theme.of(context)
                          .textTheme
                          .headline5!
                          .color!
                          .withOpacity(0.5),
                    ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yield',
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color!
                                        .withOpacity(0.5),
                                  ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          '${TokensHelper().getAprFormat(widget.assetPair.apr!)}',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color!
                                        .withOpacity(0.5),
                                  ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        TickerText(
                          child: Text(
                            '${getTotalAmountByUsd(widget.assetPair.totalLiquidityUsd!)}',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              alignment: Alignment.centerLeft,
              child: AssetPair(
                pair: widget.assetPair.symbol!,
                isTransform: false,
              ),
            ),
            Container(
              width: 97,
              padding: EdgeInsets.only(right: 2),
              child: TickerText(
                child: Row(
                  children: [
                    Container(
                      height: 23,
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.6),
                          color: isDarkTheme()
                              ? DarkColors.assetItemSelectorBorderColor
                                  .withOpacity(0.07)
                              : LightColors.assetItemSelectorBorderColor
                                  .withOpacity(0.07)),
                      child: Text(
                        widget.assetPair.tokenA!,
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontSize: 11,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Container(
                      height: 23,
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.6),
                          color: isDarkTheme()
                              ? DarkColors.assetItemSelectorBorderColor
                                  .withOpacity(0.07)
                              : LightColors.assetItemSelectorBorderColor
                                  .withOpacity(0.07)),
                      child: Text(
                        widget.assetPair.tokenB!,
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              child: Text(
                TokensHelper().getAprFormat(widget.assetPair.apr!),
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      fontSize: 12,
                    ),
              ),
            ),
            Container(
              width: 75,
              child: TickerText(
                child: Text(
                  getTotalAmountByUsd(widget.assetPair.totalLiquidityUsd!),
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String getTotalAmountByUsd(double amount) {
    BalancesHelper balancesHelper = BalancesHelper();

    String amountFormat =
        balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
    return '\$$amountFormat';
  }
}
