import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';

// ignore: must_be_immutable
class AssetList extends StatelessWidget {
  AssetList({
    Key? key,
  }) : super(key: key);

  TokensHelper tokenHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state.status == AccountStatusList.success) {
        List<BalanceModel> balances = state.activeAccount!.balanceList!
            .where((el) => !el.isHidden!)
            .toList();
        String currency = SettingsHelper.settings.currency!;

        return BlocBuilder<TokensCubit, TokensState>(
            builder: (context, tokensState) {
          if (tokensState.status == TokensStatusList.success) {
            return ListView.builder(
              itemCount: balances.length,
              itemBuilder: (context, index) {
                String coin = balances[index].token!;
                String tokenName = tokenHelper.getTokenWithPrefix(coin);
                double tokenBalance =
                    convertFromSatoshi(balances[index].balance!);

                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8, left: 16, right: 16, top: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor,
                    ),
                    child: ListTile(
                      leading: _buildTokenIcon(balances[index]),
                      title: Text(
                        getFormatTokenBalance(tokenBalance, tokenName),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(
                        getFormatTokenBalanceByFiat(
                            tokensState, coin, tokenBalance, currency),
                        style: Theme.of(context).textTheme.headline4!.apply(
                            color: SettingsHelper.settings.theme == 'dark'
                                ? Colors.white
                                : Color(0xFF7D7D7D),
                            fontSizeFactor: 0.9),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        });
      } else {
        return Container();
      }
    });
  }

  Widget _buildTokenIcon(BalanceModel token) {
    if (token.isPair!) {
      return AssetPair(pair: token.token!);
    } else {
      return SvgPicture.asset(
        tokenHelper.getImageNameByTokenName(token.token!),
        height: 40,
        width: 40,
      );
    }
  }

  String getFormatTokenBalance(double tokenBalance, String tokenName) =>
      '${balancesHelper.numberStyling(tokenBalance)} $tokenName';

  String getFormatTokenBalanceByFiat(
      state, String coin, double tokenBalance, String fiat) {
    double balanceInUsd;
    if (tokenHelper.isPair(coin)) {
      double balanceInSatoshi = convertToSatoshi(tokenBalance) + .0;
      balanceInUsd = tokenHelper.getPairsAmountByAsset(
          state.tokensPairs, balanceInSatoshi, coin, 'USD');
    } else {
      balanceInUsd =
          tokenHelper.getAmountByUsd(state.tokensPairs, tokenBalance, coin);
    }
    if (fiat == 'EUR') {
      balanceInUsd *= state.eurRate;
    }
    return '${balancesHelper.numberStyling(balanceInUsd, fixed: true)} $fiat';
  }
}
