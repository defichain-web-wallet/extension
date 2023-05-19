import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/assets/asset_logo.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';

class AssetCard extends StatefulWidget {
  final BalanceModel balanceModel;

  const AssetCard({
    Key? key,
    required this.balanceModel,
  }) : super(key: key);

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  TokensHelper tokensHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();

  String getFormatTokenBalance(double tokenBalance) =>
      '${balancesHelper.numberStyling(tokenBalance)}';

  String getFormatTokenBalanceByFiat(
      state, String coin, double tokenBalance, String fiat) {
    double balanceInUsd;
    if (tokensHelper.isPair(coin)) {
      double balanceInSatoshi = convertToSatoshi(tokenBalance) + .0;
      balanceInUsd = tokensHelper.getPairsAmountByAsset(
          state.tokensPairs, balanceInSatoshi, coin, 'USD')*2;
    } else {
      balanceInUsd = tokensHelper.getAmountByUsd(
          state.tokensPairs, tokenBalance, coin.replaceAll('d', ''));
    }
    if (fiat == 'EUR') {
      balanceInUsd *= state.eurRate;
    }
    return '\$${balancesHelper.numberStyling(balanceInUsd, fixed: true)}';
  }

  @override
  Widget build(BuildContext context) {
    String currency = SettingsHelper.settings.currency!;
var token = widget.balanceModel.lmPool ?? widget.balanceModel.token;
    return Container(
      height: 64,
      padding: const EdgeInsets.only(
        left: 10,
        top: 10,
        right: 16,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).listTileTheme.tileColor!,
        ),
        color: Theme.of(context).listTileTheme.selectedColor,
      ),
      child: Container(
        child: Row(
          children: [
            if (token!.isPair)
              AssetPair(
                pair: token.symbol
              ),
            if (!token.isPair)
              AssetLogo(
                assetStyle: tokensHelper.getAssetStyleByTokenName(
                    token.symbol),
              ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      token.displaySymbol,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    TickerText(
                      child: Text(
                        token.isPair
                            ? tokensHelper.getSpecificDefiPairName(
                            token.name)
                        //TODO: maybe bug
                            : token.name,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.3),
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    getFormatTokenBalance(convertFromSatoshi(widget.balanceModel.balance)),
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    //TODO: fix works with fiat. Move this to cubit
                    // getFormatTokenBalanceByFiat(
                    //   widget.tokensState,
                    //   widget.tokenCode,
                    //   widget.tokenBalance,
                    //   currency,
                    // ),
                    '',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .headline6!
                              .color!
                              .withOpacity(0.3),
                        ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
