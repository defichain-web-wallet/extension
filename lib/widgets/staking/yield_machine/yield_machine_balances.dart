import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataModel {
  double balance = 0;
}
class YieldMachineBalance extends StatelessWidget {
  const YieldMachineBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TokensHelper tokensHelper = TokensHelper();
    BalancesHelper balancesHelper = BalancesHelper();
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    return BlocBuilder<LockCubit, LockState>(
      builder: (context, state) {
        double totalBalance = 0;
        state.availableBalances.forEach((element) {
          if (element.balance! > 0) {
            totalBalance += tokensHelper.getAmountByUsd(
              tokensCubit.state.tokensPairs!,
              element.balance!,
              element.asset!,
            );
          }
        });
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Total deposit',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  balancesHelper.numberStyling(
                    totalBalance,
                    fixedCount: 2,
                    fixed: true,
                  ),
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'USD',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Divider(
              height: 25,
              color: Theme.of(context)
                  .dividerColor
                  .withOpacity(0.16),
            ),
            ...List.generate(
              state.availableBalances.length,
                  (index) {
                bool isNotLastEntry = index != state.availableBalances.length - 1;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${state.availableBalances[index].asset}',
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${state.availableBalances[index].balance} ${state.availableBalances[index].asset}',
                          style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (state.availableBalances[index].pendingDeposits != 0) ...[
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Pending Deposit',
                            style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${state.availableBalances[index].pendingDeposits == 0 ? '' : '+'}'
                                '${state.availableBalances[index].pendingDeposits}'
                                ' ${state.availableBalances[index].asset}',
                            style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if(state.availableBalances[index].pendingWithdrawals != 0) ...[
                      SizedBox(height: 8,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Pending Withdrowal',
                            style: Theme.of(context).textTheme.headline6!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${state.availableBalances[index].pendingWithdrawals == 0 ? '' : '-'}'
                                '${state.availableBalances[index].pendingWithdrawals}'
                                ' ${state.availableBalances[index].asset}',
                            style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .color!
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isNotLastEntry)
                      SizedBox(
                        height: 16,
                      ),
                  ],
                );
              },
            )
          ],
        );
      },
    );
  }
}
