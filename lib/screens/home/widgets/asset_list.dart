import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/home/asset_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class AssetList extends StatelessWidget {
  AssetList({
    Key? key,
  }) : super(key: key);

  TokensHelper tokenHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state.status == WalletStatusList.success) {
          late List<BalanceModel> balances;
          balances = state.activeAccount!.pinnedBalances['defichainMainnet']!;
          balances.removeWhere(
            (element) => element.lmPool != null && element.balance == 0,
          );

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
                      double tokenBalance = convertFromSatoshi(
                        balances.first.balance,
                      );
                      return Container(
                        padding: const EdgeInsets.only(
                          bottom: 4,
                          left: 16,
                          right: 16,
                          top: 2,
                        ),
                        color: Theme.of(context).cardColor,
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
            },
          );
        } else {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(),
          );
        }
      },
    );
  }
}
