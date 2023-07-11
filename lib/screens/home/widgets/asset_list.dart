import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/home/asset_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class AssetList extends StatelessWidget with ThemeMixin {
  AssetList({
    Key? key,
  }) : super(key: key);

  String getSpecificTokenName(String token) {
    switch (token) {
      case 'USD':
        return 'USDT';
      case 'EUR':
        return 'EUROC';
      default:
        return token;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatesCubit, RatesState>(
      builder: (context, ratesState) {
        print(ratesState.activeAsset);
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if ((state.status == WalletStatusList.success ||
                    state.status == WalletStatusList.update) &&
                ratesState.status == RatesStatusList.success) {
              List<BalanceModel> balances = state.getBalances();

              List<Map<String, dynamic>> availableBalances = balances.map((el) {
                double convertedBalance =
                    ratesState.ratesModel!.convertAmountBalance(
                  state.activeNetwork,
                  el,
                  convertToken: getSpecificTokenName(ratesState.activeAsset),
                );

                return <String, dynamic>{
                  'convertAmount': convertedBalance,
                  'balance': el,
                };
              }).toList();

              availableBalances.sort(
                (a, b) => b['convertAmount'].compareTo(a['convertAmount']),
              );


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
                      color: isFullScreen(context)
                          ? null
                          : Theme.of(context).cardColor,
                      child: AssetCard(
                        assetDetails: availableBalances[index],
                      ),
                    );
                  },
                  childCount: availableBalances.length,
                ),
              );
            } else {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: isFullScreen(context)
                      ? null
                      : Theme.of(context).cardColor,
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
