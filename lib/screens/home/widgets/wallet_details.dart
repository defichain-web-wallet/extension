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
  WalletDetails({Key? key}) : super(key: key);

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
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 16,
                          child: ElevatedButton(
                            onPressed: () => setState(() {
                              activeAsset = AssetList.fiat;
                            }),
                            child: Text(
                              SettingsHelper.settings.currency!,
                              style: getTextStyle(AssetList.fiat),
                            ),
                            style: getButtonStyle(AssetList.fiat),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          height: 16,
                          child: ElevatedButton(
                            onPressed: () => setState(() {
                              activeAsset = AssetList.dfi;
                            }),
                            child: Text(
                              'DFI',
                              overflow: TextOverflow.visible,
                              maxLines: 1,
                              style: getTextStyle(AssetList.dfi),
                            ),
                            style: getButtonStyle(AssetList.dfi),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          height: 16,
                          child: TextButton(
                            onPressed: () => setState(() {
                              activeAsset = AssetList.btc;
                            }),
                            child: Text(
                              'BTC',
                              style: getTextStyle(AssetList.btc),
                            ),
                            style: getButtonStyle(AssetList.btc),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        "${balancesHelper.numberStyling(totalResult, fixed: true, fixedCount: 6)} ${activeAssetName.toUpperCase()}",
                        style: Theme.of(context).textTheme.headline1!.apply(
                              fontFamily: 'IBM Plex Medium',
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
        padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: BorderSide(color: Colors.transparent))),
        shadowColor: MaterialStateProperty.all(Colors.transparent),
        backgroundColor: activeAsset == targetAsset
            ? MaterialStateProperty.all(Theme.of(context).secondaryHeaderColor)
            : MaterialStateProperty.all(Colors.transparent),
      );

  TextStyle getTextStyle(AssetList targetAsset) =>
      Theme.of(context).textTheme.subtitle2!.apply(
          fontStyle: FontStyle.normal,
          decoration: TextDecoration.none,
          color: activeAsset == targetAsset
              ? AppTheme.pinkColor
              : Theme.of(context).textTheme.subtitle2!.color);
}
