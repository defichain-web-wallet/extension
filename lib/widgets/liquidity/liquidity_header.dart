import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LiquidityHeader extends StatelessWidget {
  final List<dynamic>? allAssetPairs;
  final List<dynamic>? assetPairs;
  final double? totalTokensBalance;
  final double? totalPairsBalance;

  const LiquidityHeader(
      {Key? key,
      this.allAssetPairs,
      this.assetPairs,
      this.totalTokensBalance,
      this.totalPairsBalance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LiquidityDetails(
                    label: 'Total balance', balance: totalTokensBalance),
                LiquidityDetails(
                    label: 'Amount invested', balance: totalPairsBalance),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.only(top: 28)),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Allocation',
                style: Theme.of(context)
                    .textTheme
                    .headline3!
                    .apply(color: Color(0xFFBDBDBD))),
          ),
          LiquidityProgressList(
              assetPairs: assetPairs, allAssetPairs: allAssetPairs)
        ],
      ),
    );
  }
}

class LiquidityDetails extends StatelessWidget {
  final String? label;
  final double? balance;

  const LiquidityDetails({Key? key, this.label, this.balance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String fiat = SettingsHelper.settings.currency!;

    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, state) {
        if (state is TokensLoadedState) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label!,
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .apply(color: Color(0xFFBDBDBD))),
                Padding(padding: const EdgeInsets.symmetric(vertical: 2)),
                Text('${getBalanceFormat(balance!, state.eurRate, fiat)} $fiat',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .apply(fontSizeDelta: 3))
              ],
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }

  String getBalanceFormat(balance, eurRate, fiat) {
    BalancesHelper balancesHelper = BalancesHelper();

    if (fiat == 'EUR') {
      return balancesHelper.numberStyling(balance * eurRate, fixed: true);
    } else {
      return balancesHelper.numberStyling(balance, fixed: true);
    }
  }
}

class LiquidityProgressList extends StatelessWidget {
  final List<dynamic>? assetPairs;
  final List<dynamic>? allAssetPairs;

  const LiquidityProgressList({Key? key, this.assetPairs, this.allAssetPairs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TokensHelper tokensHelper = TokensHelper();
    int totalBalance = 0;

    assetPairs!.forEach((element) {
      totalBalance += element.balance! as int;
    });

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 100,
        minHeight: 50,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: assetPairs!.length,
        itemBuilder: (context, index) {
          Color tokenColor = tokensHelper
              .getColorByTokenName(assetPairs![index].token.split('-')[0]);
          double balancePercentage =
              1 * assetPairs![index].balance / totalBalance;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      assetPairs![index].token,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    Text(
                      '${toFixed(balancePercentage * 100, 2)} %',
                      style: Theme.of(context).textTheme.headline2!.apply(
                        color: Color(0xFFBDBDBD)
                      ),
                    ),
                  ],
                ),
                Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor.withOpacity(0.06),
                        spreadRadius: 2,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: LinearPercentIndicator(
                    padding: const EdgeInsets.all(0),
                    barRadius: Radius.circular(20),
                    lineHeight: 10,
                    percent: balancePercentage,
                    backgroundColor: Color(0xFFE9E9E9),
                    progressColor: tokenColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
