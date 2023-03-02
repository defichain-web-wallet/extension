import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/assets/asset_icon.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetCard extends StatefulWidget {
  final int index;
  final String tokenCode;
  final String tokenName;
  final double tokenBalance;
  final TokensState tokensState;
  final List<TokensModel> tokens;

  const AssetCard({
    Key? key,
    required this.index,
    required this.tokenCode,
    required this.tokenName,
    required this.tokenBalance,
    required this.tokensState,
    required this.tokens,
  }) : super(key: key);

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  TokensHelper tokensHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();

  Widget _buildTokenIcon(TokensModel token) {
    if (token.isPair!) {
      return AssetPair(pair: token.symbol!, size: 20,);
    } else {
      return AssetIcon(
        url: tokensHelper.getImageNameByTokenName(token.symbol!),
        color: tokensHelper.getColorByTokenName(token.symbol!),
      );
    }
  }

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
    return '\$${balancesHelper.numberStyling(balanceInUsd, fixed: true, fixedCount: 8)}';
  }

  @override
  Widget build(BuildContext context) {
    String currency = SettingsHelper.settings.currency!;

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
            SizedBox(
              height: 42,
              width: 42,
              child: _buildTokenIcon(widget.tokens![widget.index]),
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
                      widget.tokenName,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      tokensHelper.getSpecificDefiName(
                        widget.tokens[widget.index].name!,
                      ),
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .headline6!
                                .color!
                                .withOpacity(0.3),
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
                    getFormatTokenBalance(widget.tokenBalance),
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    getFormatTokenBalanceByFiat(
                      widget.tokensState,
                      widget.tokenCode,
                      widget.tokenBalance,
                      currency,
                    ),
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
