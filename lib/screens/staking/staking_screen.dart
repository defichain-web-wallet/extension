import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:defi_wallet/screens/error_screen.dart';
import 'package:defi_wallet/screens/staking/stake_unstake_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/staking/reward_icon.dart';
import 'package:defi_wallet/widgets/staking/reward_routes.dart';
import 'package:defi_wallet/widgets/staking/staking_header.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({
    Key? key,
  }) : super(key: key);

  @override
  _StakingScreenState createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen>
    with ThemeMixin, SnackBarMixin {
  final String titleText = 'Staking';
  final String headerTextYieldMachine = 'Yield Machine by LOCK';
  bool isEdit = false;
  bool isFirstBuild = true;
  TextEditingController controller = TextEditingController();
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  late List<Widget> rewards;

  _onSaveRewardRoutes(BuildContext context) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);

    lockCubit.updateRewardRoutes(
      walletCubit.state.activeNetwork,
    );
    setState(() {
      isEdit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<LockCubit, LockState>(
          builder: (lockContext, lockState) {
            if (lockState.status == LockStatusList.success) {
              List<RewardRouteModel> rewards = lockState.rewards();
              controllers = List.generate(rewards.length, (index) {
                return TextEditingController(
                    text: (rewards[index].rewardPercent! * 100).toString());
              });
              focusNodes = List.generate(rewards.length, (index) => FocusNode());
              controller.text =
                  '${1 * 100}';

              return Scaffold(
                drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                endDrawer: isFullScreen ? null : AccountDrawer(
                  width: buttonSmallWidth,
                ),
                appBar: isFullScreen ? null : NewMainAppBar(
                  bgColor: AppColors.viridian.withOpacity(0.16),
                  isShowLogo: false,
                  isShowNetworkSelector: false,
                  callback: () {},
                ),
                body: Container(
                  decoration: BoxDecoration(
                    color: isFullScreen ? null : AppColors.viridian.withOpacity(0.16) ,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        StakingHeader(
                          apr: lockState.stakingTokenModel!.apr!,
                          apy: lockState.stakingTokenModel!.apy!,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 22,
                            bottom: 24,
                            left: 16,
                            right: 16,
                          ),
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 541),
                          decoration: BoxDecoration(
                            color: isDarkTheme()
                                ? DarkColors.scaffoldContainerBgColor
                                : LightColors.scaffoldContainerBgColor,
                            border: isDarkTheme()
                                ? Border.all(
                                    width: 1.0,
                                    color: Colors.white.withOpacity(0.05),
                                  )
                                : null,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                              bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                            ),
                          ),
                          child: StretchBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                PageTitle(
                                  title: titleText,
                                  isFullScreen: isFullScreen,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                // StakingTabs(
                                //   lockStrategy: lockState.lockStrategy,
                                // ),
                                SizedBox(
                                  height: 24,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          AppColors.portageBg.withOpacity(0.24),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${lockState.stakingModel!.balances[0].asset} Staking',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                            Text(
                                              '${lockState.stakingModel!.balances[0].balance} ${lockState.stakingModel!.balances[0].asset}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Pending Deposits ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .color!
                                                        .withOpacity(0.5),
                                                  ),
                                            ),
                                            Text(
                                              '${lockState.stakingModel!.balances[0].pendingDeposits == 0 ? '' : '+'}'
                                              '${lockState.stakingModel!.balances[0].pendingDeposits}'
                                              ' ${lockState.stakingModel!.balances[0].asset}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .copyWith(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .color!
                                                        .withOpacity(0.8),
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Pending Withdrawals ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .color!
                                                        .withOpacity(0.5),
                                                  ),
                                            ),
                                            Text(
                                              '${lockState.stakingModel!.balances[0].pendingWithdrawals == 0 ? '' : '-'}'
                                              '${lockState.stakingModel!.balances[0].pendingWithdrawals}'
                                              ' ${lockState.stakingModel!.balances[0].asset}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .copyWith(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .color!
                                                        .withOpacity(0.8),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    // else
                                    //     YieldMachineBalance(),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.portageBg
                                              .withOpacity(0.07),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Reward strategy ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .copyWith(
                                                        fontSize: 16,
                                                      ),
                                                ),
                                                RewardIcon(
                                                  readonly: isEdit,
                                                  onTap: (value) {
                                                    setState(() {
                                                      isEdit = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            RewardRoutesList(
                                              controllers: controllers,
                                              focusNodes: focusNodes,
                                              isDisabled: isEdit,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      if (!isEdit)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: AccentButton(
                                                label: 'Unstake',
                                                callback: () {
                                                  NavigatorService.push(context, StakeUnstakeScreen(
                                                    isUnstake: true,
                                                  ));
                                                },
                                              ),
                                            ),
                                            NewPrimaryButton(
                                              width: 140,
                                              title: 'Stake',
                                              callback: () {
                                                NavigatorService.push(context, StakeUnstakeScreen(
                                                  isUnstake: false,
                                                ));
                                              },
                                            )
                                          ],
                                        ),
                                      if (isEdit)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: AccentButton(
                                                label: 'Cancel',
                                                callback: () {
                                                  setState(() {
                                                    isEdit = false;
                                                  });
                                                },
                                              ),
                                            ),
                                            NewPrimaryButton(
                                              width: 140,
                                              title: 'Save',
                                              callback: () =>
                                                  _onSaveRewardRoutes(context),
                                            )
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (lockState.status == LockStatusList.failure) {
              return ErrorScreen();
            } else {
              return Loader();
            }
          },
        );
      },
    );
  }
}
