import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AssetList { fiat, dfi, btc }

class WalletDetails extends StatefulWidget {
  late final String layoutSize;

  WalletDetails({Key? key, required this.layoutSize}) : super(key: key);

  @override
  State<WalletDetails> createState() => _WalletDetailsState();
}

class _WalletDetailsState extends State<WalletDetails> {
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokensHelper = TokensHelper();
  AssetList activeAsset = AssetList.fiat;
  late String activeAssetName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, tokensState) {
        return BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
          if (state.status == AccountStatusList.success &&
              tokensState.status == TokensStatusList.success) {
            int totalBalance = state.activeAccount!.balanceList!
                .where((el) => !el.isHidden!)
                .map<int>((e) => e.balance!)
                .reduce((value, element) => value + element);
            double convertTotalBalance = convertFromSatoshi(totalBalance);

            double totalResult = convertTotalBalance;
            if (activeAsset == AssetList.fiat) {
              totalResult = tokensHelper.getAmountByUsd(
                tokensState.tokensPairs!,
                convertTotalBalance,
                'DFI',
              );
              if (SettingsHelper.settings.currency == 'EUR') {
                totalResult *= tokensState.eurRate!;
              }
            } else if (activeAsset == AssetList.btc) {
              totalResult = tokensHelper.getAmountByBtc(
                tokensState.tokensPairs!,
                convertTotalBalance,
                'DFI',
              );
            }

            activeAssetName = activeAsset == AssetList.fiat
                ? SettingsHelper.settings.currency!
                : activeAsset.name;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() {
                            activeAsset = AssetList.fiat;
                          }),
                          child: Text(
                            SettingsHelper.settings.currency!,
                            style: getTextStyle(AssetList.fiat),
                          ),
                          style: getButtonStyle(AssetList.fiat),
                        ),
                        SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            activeAsset = AssetList.dfi;
                          }),
                          child: Text(
                            'DFI',
                            style: getTextStyle(AssetList.dfi),
                          ),
                          style: getButtonStyle(AssetList.dfi),
                        ),
                        SizedBox(width: 24),
                        TextButton(
                          onPressed: () => setState(() {
                            activeAsset = AssetList.btc;
                          }),
                          child: Text(
                            'BTC',
                            style: getTextStyle(AssetList.btc),
                          ),
                          style: getButtonStyle(AssetList.btc),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        "${balancesHelper.numberStyling(totalResult, fixed: true, fixedCount: 6)} ${activeAssetName.toUpperCase()}",
                        style: Theme.of(context).textTheme.headline1!.apply(
                              fontWeightDelta: 1,
                              fontFamily: 'IBM Plex Sans',
                            ),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        });
      },
    );
  }

  ButtonStyle getButtonStyle(AssetList targetAsset) => ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.transparent))),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        backgroundColor: activeAsset == targetAsset
            ? MaterialStateProperty.all(Theme.of(context).secondaryHeaderColor)
            : MaterialStateProperty.all(Colors.transparent),
      );

  TextStyle getTextStyle(AssetList targetAsset) =>
      Theme.of(context).textTheme.headline3!.apply(
          color: activeAsset == targetAsset
              ? AppTheme.pinkColor
              : Theme.of(context).textTheme.headline3!.color);

  String getBalanceByUsd(state, balance, token, currency) {
    double balanceByUsd;
    if (tokensHelper.isPair(token)) {
      double satoshi = convertToSatoshi(balance) + .0;
      balanceByUsd =
          tokensHelper.getPairsAmountByUsd(state.tokensPairs, satoshi, token);
    } else {
      balanceByUsd =
          tokensHelper.getAmountByUsd(state.tokensPairs, balance, token);
    }
    if (currency == 'EUR') {
      balanceByUsd *= state.eurRate;
    }
    return "${balancesHelper.numberStyling(balanceByUsd, fixed: true, fixedCount: 2)} $currency";
  }
}
