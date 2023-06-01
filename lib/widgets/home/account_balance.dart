import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/common/balance_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountBalance extends StatefulWidget {
  final String asset;
  final bool isSmall;

  const AccountBalance({
    Key? key,
    required this.asset,
    this.isSmall = false,
  }) : super(key: key);

  @override
  State<AccountBalance> createState() => _AccountBalanceState();
}

class _AccountBalanceState extends State<AccountBalance> {
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokensHelper = TokensHelper();
  SettingsHelper settingsHelper = SettingsHelper();
  late String activeAssetName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, tokensState) {
        return BlocBuilder<BitcoinCubit, BitcoinState>(
          builder: (context, bitcoinState) {
            return BlocBuilder<WalletCubit, WalletState>(
                builder: (context, state) {
              if (state.status == WalletStatusList.success &&
                  tokensState.status == TokensStatusList.success) {
                late double totalBalance;
                late double unconfirmedBalance;
                late double totalBtcBalance;

                try {
                  var balanceList =
                      state.activeAccount.pinnedBalances['defichainMainnet'];
                  totalBalance = balanceList!.map<double>((e) {
                    if (e.token != null) {
                      if (widget.asset == 'USD') {
                        return tokensHelper.getAmountByUsd(
                          tokensState.tokensPairs!,
                          convertFromSatoshi(e.balance),
                          e.token!.symbol,
                        );
                      } else if (widget.asset == 'EUR') {
                        var a = tokensHelper.getAmountByUsd(
                          tokensState.tokensPairs!,
                          convertFromSatoshi(e.balance),
                          e.token!.symbol,
                        );
                        return a * tokensState.eurRate!;
                      } else {
                        return tokensHelper.getAmountByBtc(
                          tokensState.tokensPairs!,
                          convertFromSatoshi(e.balance),
                          e.token!.symbol,
                        );
                      }
                    } else {
                      double balanceInSatoshi =
                          double.parse(e.balance.toString());
                      if (widget.asset == 'USD') {
                        return tokensHelper.getPairsAmountByAsset(
                          tokensState.tokensPairs!,
                          balanceInSatoshi,
                          e.lmPool!.symbol,
                          widget.asset,
                        );
                      } else if (widget.asset == 'EUR') {
                        var b = tokensHelper.getPairsAmountByAsset(
                          tokensState.tokensPairs!,
                          balanceInSatoshi,
                          e.lmPool!.symbol,
                          widget.asset,
                        );
                        return b * tokensState.eurRate!;
                      } else {
                        return tokensHelper.getPairsAmountByAsset(
                          tokensState.tokensPairs!,
                          balanceInSatoshi,
                          e.lmPool!.symbol,
                          widget.asset,
                        );
                      }
                    }
                  }).reduce((value, element) => value + element);
                } catch (error) {
                  print(error);
                  totalBalance = 0.00;
                }

                return Container(
                  child: BalanceText(
                    isSmallFont: widget.isSmall,
                    balance: totalBalance,
                    assetName: widget.asset,
                  ),
                );
              } else {
                return Container();
              }
            });
          },
        );
      },
    );
  }
}
