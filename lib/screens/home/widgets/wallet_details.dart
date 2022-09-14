import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
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
  SettingsHelper settingsHelper = SettingsHelper();
  AssetList activeAsset = AssetList.fiat;
  late String activeAssetName;

  @override
  Widget build(BuildContext context) {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);

    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, tokensState) {
        return BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
          if (state.status == AccountStatusList.success &&
              tokensState.status == TokensStatusList.success) {
            late double totalBalance;
            late double totalBalanceInFiat;
            if (SettingsHelper.isBitcoin()) {
              activeAsset = AssetList.btc;
              totalBalance = convertFromSatoshi(bitcoinCubit.state.totalBalance);
              totalBalanceInFiat = tokensHelper.getAmountByUsd(
                tokensState.tokensPairs!,
                totalBalance,
                'BTC',
              );
              if (SettingsHelper.settings.currency == 'EUR') {
                totalBalanceInFiat *= tokensState.eurRate!;
              }
            } else {
              totalBalance = state.activeAccount!.balanceList!
                  .where((el) => !el.isHidden!)
                  .map<double>((e) {
                if (!e.isPair!) {
                  if (activeAsset == AssetList.fiat) {
                    return tokensHelper.getAmountByUsd(
                      tokensState.tokensPairs!,
                      convertFromSatoshi(e.balance!),
                      e.token!,
                    );
                  } else if (activeAsset == AssetList.dfi) {
                    return tokensHelper.getAmountByDfi(
                      tokensState.tokensPairs!,
                      convertFromSatoshi(e.balance!),
                      e.token!,
                    );
                  } else {
                    return tokensHelper.getAmountByBtc(
                      tokensState.tokensPairs!,
                      convertFromSatoshi(e.balance!),
                      e.token!,
                    );
                  }
                } else {
                  double balanceInSatoshi = double.parse(e.balance!.toString());
                  if (activeAsset == AssetList.fiat) {
                    return tokensHelper.getPairsAmountByAsset(
                        tokensState.tokensPairs!, balanceInSatoshi, e.token!, 'USD');
                  } else if (activeAsset == AssetList.dfi) {
                    return tokensHelper.getPairsAmountByAsset(
                        tokensState.tokensPairs!, balanceInSatoshi, e.token!, 'DFI');
                  } else {
                    return tokensHelper.getPairsAmountByAsset(
                        tokensState.tokensPairs!, balanceInSatoshi, e.token!, 'BTC');
                  }
                }
              }).reduce((value, element) => value + element);
            }

            if (activeAsset == AssetList.fiat) {
              if (SettingsHelper.settings.currency == 'EUR') {
                totalBalance *= tokensState.eurRate!;
              }
            }

            activeAssetName = activeAsset == AssetList.fiat
                ? SettingsHelper.settings.currency!
                : activeAsset.name;

            return Container(
              child: Column(
                children: [
                  if (!SettingsHelper.isBitcoin())
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
                      )
                  else
                    Text(
                      "Total value: ${balancesHelper.numberStyling(totalBalanceInFiat, fixed: true, fixedCount: 2)} ${SettingsHelper.settings.currency}",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    child: Center(
                      child: Text(
                        "${balancesHelper.numberStyling(totalBalance, fixed: true, fixedCount: 6)} ${activeAssetName.toUpperCase()}",
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
