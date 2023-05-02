import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/widgets/selectors/selector_tab_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StakingTabs extends StatelessWidget {
  final LockStrategyList lockStrategy;
  const StakingTabs({Key? key, required this.lockStrategy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    return BlocBuilder<LockCubit, LockState>(
      builder: (context, state) {
        return Row(
          children: [
            SelectorTabElement(
              callback: () {
                lockCubit.updateLockStrategy(
                  LockStrategyList.Masternode,
                  accountCubit.state.accounts!.first,
                );
              },
              title: 'Staking',
              isSelect: state.lockStrategy == LockStrategyList.Masternode,
            ),
            SizedBox(
              width: 24,
            ),
            SelectorTabElement(
              callback: () {
                lockCubit.updateLockStrategy(
                  LockStrategyList.LiquidityMining,
                  accountCubit.state.accounts!.first,
                );
              },
              isSelect: state.lockStrategy == LockStrategyList.LiquidityMining,
              title: 'Yield machine',
            )
          ],
        );
      },
    );
  }
}
