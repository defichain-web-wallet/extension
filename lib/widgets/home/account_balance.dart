import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/common/balance_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

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
            return BlocBuilder<AccountCubit, AccountState>(
                builder: (context, state) {
                  if (state.status == AccountStatusList.success &&
                      tokensState.status == TokensStatusList.success) {
                    late double totalBalance;
                    late double unconfirmedBalance;
                    late double totalBtcBalance;
                    if (SettingsHelper.isBitcoin()) {
                      if (widget.asset == 'USD') {
                        totalBalance = tokensHelper.getAmountByUsd(
                          tokensState.tokensPairs!,
                          convertFromSatoshi(bitcoinState.totalBalance),
                          'BTC',
                        );
                      } else if (widget.asset == 'EUR') {
                        var a = tokensHelper.getAmountByUsd(
                          tokensState.tokensPairs!,
                          convertFromSatoshi(bitcoinState.totalBalance),
                          'BTC',
                        );
                        totalBalance = a * tokensState.eurRate!;
                      } else {
                        totalBalance = convertFromSatoshi(bitcoinState.totalBalance);
                      }
                      unconfirmedBalance = convertFromSatoshi(bitcoinState.unconfirmedBalance);
                    } else {
                      totalBalance = state.activeAccount!.balanceList!
                          .where((el) => !el.isHidden!)
                          .map<double>((e) {
                        if (!e.isPair!) {
                          if (widget.asset == 'USD') {
                            return tokensHelper.getAmountByUsd(
                              tokensState.tokensPairs!,
                              convertFromSatoshi(e.balance!),
                              e.token!,
                            );
                          } else if (widget.asset == 'EUR') {
                            var a = tokensHelper.getAmountByUsd(
                              tokensState.tokensPairs!,
                              convertFromSatoshi(e.balance!),
                              e.token!,
                            );
                            return a * tokensState.eurRate!;
                          } else {
                            return tokensHelper.getAmountByBtc(
                              tokensState.tokensPairs!,
                              convertFromSatoshi(e.balance!),
                              e.token!,
                            );
                          }
                        } else {
                          double balanceInSatoshi = double.parse(e.balance!.toString());
                          if (widget.asset == 'USD') {
                            return tokensHelper.getPairsAmountByAsset(
                                tokensState.tokensPairs!, balanceInSatoshi, e.token!, 'USD');
                          } else if (widget.asset == 'EUR') {
                            var b = tokensHelper.getPairsAmountByAsset(
                                tokensState.tokensPairs!, balanceInSatoshi, e.token!, 'USD');
                            return b * tokensState.eurRate!;
                          } else {
                            return tokensHelper.getPairsAmountByAsset(
                                tokensState.tokensPairs!, balanceInSatoshi, e.token!, 'BTC');
                          }
                        }
                      }).reduce((value, element) => value + element);
                    }

                    return Container(
                      child: BalanceText(
                        isSmallFont: widget.isSmall,
                        balance: totalBalance,
                        assetName: widget.asset,
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        SizedBox(height: 42.0,),
                        SizedBox(
                          width: 128.0,
                          height: 10.0,
                          child: Shimmer.fromColors(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              baseColor: Color(0xFFD0CDD4),
                              highlightColor: Color(0xFFE0DDE4)),
                        ),
                      ],
                    );
                  }
                });
          },
        );
      },
    );
  }
}
