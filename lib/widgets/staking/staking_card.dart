import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/helpers/access_token_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/screens/earn/earn_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StakingCard extends StatelessWidget {
  final Function() loadEarnData;
  final Function() callback;

  const StakingCard({
    Key? key,
    required this.loadEarnData,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(LockStrategyList.Masternode.toString());
    return BlocBuilder<LockCubit, LockState>(builder: (context, lockState) {
      var isLoading = lockState.status == LockStatusList.initial ||
          lockState.status == LockStatusList.loading;
      var isExpiredAccessToken = lockState.status == LockStatusList.expired;
      LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      if (lockState.status == LockStatusList.success || isLoading) {
        return EarnCard(
          isLoading: isLoading,
          title: 'Staking',
          subTitle: isLoading
              ? ''
              : 'up to '
                  '${BalancesHelper().numberStyling(
                  (lockState.lockAnalyticsDetails!.apy! * 100),
                  fixed: true,
                  fixedCount: 2,
                )}% APY',
          imagePath: 'assets/images/dfi_staking.png',
          firstColumnNumber: isLoading
              ? ''
              : lockCubit.checkVerifiedUser()
                  ? BalancesHelper().numberStyling(
                      lockState.lockStakingDetails!.balance!,
                      fixed: true,
                      fixedCount: 2,
                    )
                  : '0.00',
          firstColumnAsset: lockCubit.checkVerifiedUser()
              ? lockState.lockStakingDetails!.asset!
              : 'DFI',
          firstColumnSubTitle: 'Staked',
          isStaking: true,
          needUpdateAccessToken: false,
          errorMessage: 'Need to create account of LOCK',
          callback: () {
            bool isEmptyToken =
                accountCubit.state.accounts!.first.lockAccessToken == null ||
                    accountCubit.state.accounts!.first.lockAccessToken!.isEmpty;
            if (isEmptyToken || isExpiredAccessToken) {
              var needDfxToken =
                  accountCubit.state.accounts!.first.accessToken == null ||
                      accountCubit.state.accounts!.first.accessToken!.isEmpty;
              AccessTokenHelper.setupLockAccessToken(
                context,
                loadEarnData,
                needUpdateDfx: needDfxToken || isExpiredAccessToken,
                dialogMessage:
                    'Please entering your password for create account',
              );
            } else {
              if (!isLoading) {
                callback();
              }
            }
          },
        );
      } else if (lockState.status == LockStatusList.expired) {
        return EarnCard(
          isLoading: isLoading,
          title: 'Staking',
          subTitle: '',
          imagePath: 'assets/images/dfi_staking.png',
          firstColumnNumber: '0.00',
          firstColumnAsset: '\$',
          firstColumnSubTitle: 'Staked',
          isStaking: true,
          needUpdateAccessToken: true,
          errorMessage: 'Need to update access token of LOCK',
          callback: () async {
            lockCubit.setLoadingState();
            await AccessTokenHelper.setupLockAccessToken(context, loadEarnData,
                needUpdateDfx: true,
                isExistingAccount: true,
                dialogMessage:
                    'Please entering your password for restore connecting to LOCK');
          },
        );
      } else {
        //TODO: add error card if LOCK is offline
        return Text('LOCK is offline');
      }
    });
  }
}
