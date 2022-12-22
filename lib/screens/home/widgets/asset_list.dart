import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
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
      return BlocBuilder<BitcoinCubit, BitcoinState>(
          builder: (context, bitcoinState) {
        if (state.status == AccountStatusList.success) {
          late List<BalanceModel> balances;
          if (SettingsHelper.isBitcoin()) {
            balances = List.generate(
                1,
                (index) => BalanceModel(
                      token: 'BTC',
                      balance: bitcoinState.totalBalance,
                    ));
          } else {
            balances = state.activeAccount!.balanceList!
                .where((el) => !el.isHidden!)
                .toList();
          }
          String currency = SettingsHelper.settings.currency!;

          return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) {
            if (tokensState.status == TokensStatusList.success) {
              return ListView.builder(
                itemCount: balances.length,
                itemBuilder: (context, index) {
                  String coin = balances[index].token!;
                  String tokenName = SettingsHelper.isBitcoin()
                      ? coin
                      : tokenHelper.getTokenWithPrefix(coin);
                  double tokenBalance =
                      convertFromSatoshi(balances[index].balance!);

                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 8, left: 16, right: 16, top: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).listTileTheme.tileColor!,
                        ),
                        color: Theme.of(context).listTileTheme.selectedColor,
                      ),
                      child: ListTile(
                        leading: _buildTokenIcon(balances[index]),
                        title: Text(
                          tokenName,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              getFormatTokenBalance(tokenBalance),
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              getFormatTokenBalanceByFiat(
                                  tokensState, coin, tokenBalance, currency),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .color!
                                        .withOpacity(0.3),
                                  ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          tokenName,
                          style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .headline6!
                                .color!
                                .withOpacity(0.3),
                          ),
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

  String getFormatTokenBalance(double tokenBalance) =>
      '${balancesHelper.numberStyling(tokenBalance)}';

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
    return '\$${balancesHelper.numberStyling(balanceInUsd, fixed: true)}';
  }
}
