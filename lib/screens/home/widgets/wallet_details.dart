import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/screens/home/widgets/asset_selector.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletDetails extends StatefulWidget {
  late final String layoutSize;

  WalletDetails({Key? key, required this.layoutSize}) : super(key: key);

  @override
  State<WalletDetails> createState() => _WalletDetailsState();
}

class _WalletDetailsState extends State<WalletDetails> {
  var balancesHelper = BalancesHelper();
  TokensHelper tokensHelper = TokensHelper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, tokensState) {
        return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
          if (state.status == AccountStatusList.success && tokensState.status == TokensStatusList.success) {
            var activeToken = state.activeAccount!.activeToken!;
            var balances = state.activeAccount!.balanceList!
                .where((el) => !el.isHidden!)
                .toList();
            var balance = balances
                .firstWhere((el) => el.token == activeToken)
                .balance!;
            return SizedBox(
              height: widget.layoutSize == 'small' ? 200 : 250,
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildBalance(
                          balance, activeToken, SettingsHelper.settings.currency!),
                      AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            pieTouchData:
                            PieTouchData(touchCallback: (pieTouchResponse) {}),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 0,
                            centerSpaceRadius: 80,
                            sections:
                            showingSections(balances, activeToken, tokensState),
                          ),
                          swapAnimationDuration: Duration.zero,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    height: widget.layoutSize == 'small' ? 200 : 250,
                    child: AssetSelector(layoutSize: widget.layoutSize),
                  ),
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

  List<PieChartSectionData> showingSections(balances, activeToken, tokensState) {
    return List.generate(balances.length, (i) {
      final balance = balances[i];

      int _averageBalanceAmount = 0;
      _averageBalanceAmount = getAverageBalanceAmount(balances, tokensState.tokensPairs);
      var balanceUsd = tokensHelper.getAmountByUsd(tokensState.tokensPairs,
          convertFromSatoshi(balances[i].balance), balances[i].token, 'USD');
      var balanceValue =
          (balanceUsd == 0 || balanceUsd < 1) ? 10 : balanceUsd;
      balanceValue = (balanceValue + _averageBalanceAmount).round();
      double radius = (balance.token == activeToken) ? 9 : 5;
      return PieChartSectionData(
        color: balance.color,
        showTitle: false,
        radius: radius,
        value: double.parse(balanceValue.toString()),
      );
    });
  }

  Widget _buildBalance(int balance, String coin, String currency) {
    var tokenName = TokensHelper().getTokenFormat(coin);
    var tokenBalance = convertFromSatoshi(balance);

    return BlocBuilder<TokensCubit, TokensState>(
      builder: (context, state) {
        if (state.status == TokensStatusList.success) {
          return Container(
            width: 140,
            height: 170,
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 65,
                  ),
                  Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          "${balancesHelper.numberStyling(tokenBalance)} $tokenName",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        )),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(getBalanceByUsd(state, tokenBalance, coin, currency))
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }

  int getAverageBalanceAmount(balances, tokensPairs) {
    double temp = 0;
    for (var el in balances) {
      temp += tokensHelper.getAmountByUsd(
          tokensPairs, convertFromSatoshi(el.balance), el.token, 'USD');
    }
    return (temp / balances.length).round();
  }

  String getBalanceByUsd(state, balance, token, currency) {
    double balanceByUsd;
    if (tokensHelper.isPair(token)) {
      double satoshi = convertToSatoshi(balance) + .0;
      balanceByUsd = tokensHelper.getPairsAmountByUsd(state.tokensPairs, satoshi, token, currency);
    } else {
      balanceByUsd = tokensHelper.getAmountByUsd(state.tokensPairs, balance, token, currency);
    }
    if (currency == 'EUR') {
      balanceByUsd *= state.eurRate;
    }
    return "${balancesHelper.numberStyling(balanceByUsd, fixed: true, fixedCount: 2)} $currency";
  }
}
