import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/home/asset_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class AssetList extends StatelessWidget with ThemeMixin {
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
            balances.removeWhere(
                (element) => element.isPair! && element.balance == 0);
            balances.sort((a, b) => b.balance!.compareTo(a.balance!));
          }
          String currency = SettingsHelper.settings.currency!;

          return BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) {
            if (tokensState.status == TokensStatusList.success) {
              List<TokensModel> tokens = tokenHelper.getTokensList(
                balances,
                tokensState,
              );

              return SliverFixedExtentList(
                itemExtent: 64.0 + 6,
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    String coin = tokens[index].symbol!;
                    String tokenName = SettingsHelper.isBitcoin()
                        ? coin
                        : tokenHelper.getTokenWithPrefix(coin);
                    double tokenBalance = convertFromSatoshi(balances
                        .firstWhere((element) => element.token == coin)
                        .balance!);
                    return Container(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                        left: 16,
                        right: 16,
                        top: 2,
                      ),
                      color: isFullScreen(context)
                          ? null
                          : Theme.of(context).cardColor,
                      child: AssetCard(
                        index: index,
                        tokenBalance: tokenBalance,
                        tokenName: tokenName,
                        tokenCode: tokenName,
                        tokensState: tokensState,
                        tokens: tokens,
                      ),
                    );
                  },
                  childCount: tokens.length,
                ),
              );
            } else {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: Center(
                    child: Text('Not yet any tokens'),
                  ),
                ),
              );
            }
          });
        } else {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(),
          );
        }
      });
    });
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
