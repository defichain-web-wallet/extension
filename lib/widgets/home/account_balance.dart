import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatesCubit, RatesState>(
      builder: (context, ratesState) {
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            if ((state.status == WalletStatusList.success ||
                state.status == WalletStatusList.update) &&
                ratesState.status == RatesStatusList.success) {
              late double totalBalance;
              late double unconfirmedBalance;

              try {
                List<BalanceModel> balances = state.getBalances();
                unconfirmedBalance = state.unconfirmedBalance();
                totalBalance = ratesState.ratesModel!.getTotalAmount(
                  state.activeNetwork,
                  balances,
                  convertToken: ratesState.ratesModel!.getSpecificTokenName(
                    widget.asset,
                  ),
                  ethereumRateModel: ratesState.ethereumRateModel,
                );
              } catch (_) {
                totalBalance = 0.00;
                unconfirmedBalance = 0.00;
              }

              return Container(
                child: BalanceText(
                  isSmallFont: widget.isSmall,
                  balance: totalBalance,
                  assetName: widget.asset,
                  unconfirmedBalance: unconfirmedBalance
                ),
              );
            } else {
              return Container(
                child: BalanceText(
                  isSmallFont: widget.isSmall,
                  balance: 0,
                  assetName: widget.asset,
                ),
              );
            }
          },
        );
      },
    );
  }
}
