import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
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
    return BlocBuilder<RatesCubit, RatesState>(
      builder: (context, ratesState) {
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if (state.status == WalletStatusList.success &&
                ratesState.status == RatesStatusList.success) {
              List<BalanceModel> balances = state.getBalances();

              return SliverFixedExtentList(
                itemExtent: 64.0 + 6,
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.only(
                        bottom: 4,
                        left: 16,
                        right: 16,
                        top: 2,
                      ),
                      color: Theme.of(context).cardColor,
                      child: AssetCard(
                        balanceModel: balances[index],
                      ),
                    );
                  },
                  childCount: balances.length,
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
      },
    );
  }
}
