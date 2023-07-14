import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/screens/earn/earn_card.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_start_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StakingCard extends StatelessWidget {
  const StakingCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LockCubit, LockState>(builder: (context, lockState) {
      LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
      var isLoading = lockState.status == LockStatusList.initial ||
          lockState.status == LockStatusList.loading;
      if (lockState.status == LockStatusList.success || isLoading) {
        return EarnCard(
          isLoading: isLoading,
          title: 'Staking',
          subTitle: lockState.lockAccountPresent!
              ? 'up to '
                  '${BalancesHelper().numberStyling(
                  (lockState.stakingTokenModel!.apy! * 100),
                  fixed: true,
                  fixedCount: 2,
                )}% APY'
              : 'N/A',
          imagePath: 'assets/images/dfi_staking.png',
          firstColumnNumber: isLoading
              ? ''
              : lockState.lockAccountPresent!
                  ? BalancesHelper().numberStyling(
                      lockState.stakingModel!.balances.first.balance,
                      fixed: true,
                      fixedCount: 2,
                    )
                  : '0.00',
          firstColumnAsset: lockState.lockAccountPresent!
              ? lockState.stakingModel!.balances.first.asset
              : 'DFI',
          firstColumnSubTitle: 'Staked',
          isStaking: true,
          needUpdateAccessToken: false,
          errorMessage: 'Need to create account of LOCK',
          callback: () {
            if (!isLoading) {
              stakingCallback(context);
            }
          },
        );
      } else if (lockState.status == LockStatusList.notFound ||
          lockState.status == LockStatusList.neededKyc ||
          lockState.status == LockStatusList.expired) {
        return EarnCard(
          isLoading: isLoading,
          title: 'Staking',
          subTitle: 'N/A APY',
          imagePath: 'assets/images/dfi_staking.png',
          firstColumnNumber: 'N/A',
          firstColumnAsset: '',
          firstColumnSubTitle: 'Staked',
          isStaking: true,
          needUpdateAccessToken: false,
          errorMessage: lockState.status == LockStatusList.notFound ||
                  lockState.status == LockStatusList.expired
              ? 'Need to create access token of LOCK'
              : 'Need to pass KYC of LOCK',
          callback: () async {
            if (lockState.status == LockStatusList.neededKyc) {
              stakingCallback(context);
            } else
              showDialog(
                barrierColor: AppColors.tolopea.withOpacity(0.06),
                barrierDismissible: false,
                context: context,
                builder: (BuildContext dialogContext) {
                  return PassConfirmDialog(
                    onCancel: () {},
                    onSubmit: (password) async {
                      if (lockState.status == LockStatusList.notFound) {
                        await lockCubit.signUp(context, password);
                      } else {
                        await lockCubit.signIn(context, password);
                      }
                      await stakingCallback(context);
                    },
                  );
                },
              );
          },
        );
      } else {
        //TODO: add error card if LOCK is offline
        return Text('LOCK is offline');
      }
    });
  }

  stakingCallback(context) async {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    if (lockCubit.state.isKycDone!) {
      NavigatorService.push(context, StakingScreen());
    } else {
      NavigatorService.push(context, StakingKycStartScreen());
    }
  }
}
