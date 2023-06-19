import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/lock_reward_routes_model.dart';
import 'package:defi_wallet/screens/error_screen.dart';
import 'package:defi_wallet/screens/staking/stake_unstake_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/invested_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/staking/reward_icon.dart';
import 'package:defi_wallet/widgets/staking/reward_routes.dart';
import 'package:defi_wallet/widgets/staking/staking_tabs.dart';
import 'package:defi_wallet/widgets/staking/yield_machine/yield_machine_balances.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final String headerTextStaking = 'DFI Staking by LOCK';
  final String headerTextYieldMachine = 'Yield Machine by LOCK';
  bool isEdit = false;
  bool isFirstBuild = true;
  TextEditingController controller = TextEditingController();
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  late List<Widget> rewards;

  _onSaveRewardRoutes(BuildContext context) {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    // lockCubit.updateRewardRoutes(
    //   accountCubit.state.accounts!.first,
    //   lockCubit.state.lockStakingDetails!.rewardRoutes!,
    // );
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
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
        return BlocBuilder<LockCubit, LockState>(
          builder: (lockContext, lockState) {
            if (lockState.status == LockStatusList.success) {
              // List<LockRewardRoutesModel> rewards =
              //     lockState.lockStakingDetails!.rewardRoutes!;
              // controllers = List.generate(rewards.length, (index) {
              //   return TextEditingController(
              //       text: (rewards[index].rewardPercent! * 100).toString());
              // });
              focusNodes = List.generate(rewards.length, (index) => FocusNode());
              controller.text =
                  '${1 * 100}';

              return Scaffold(
                drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                endDrawer: AccountDrawer(
                  width: buttonSmallWidth,
                ),
                appBar: NewMainAppBar(
                  bgColor: AppColors.viridian.withOpacity(0.16),
                  isShowLogo: false,
                  isShowNetworkSelector: false,
                  callback: () {
                    // lockCubit.updateLockStrategy(
                    //   LockStrategyList.Masternode,
                    //   accountCubit.state.accounts!.first,
                    // );
                  },
                ),
                body: Container(
                  decoration: BoxDecoration(
                      color: AppColors.viridian.withOpacity(0.16)),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 8,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 20,
                                    ),
                                    padding: EdgeInsets.only(top: 38),
                                    width: 328,
                                    height: 123,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: isDarkTheme()
                                          ? AppColors.white.withOpacity(0.04)
                                          : LightColors
                                              .scaffoldContainerBgColor,
                                      border: isDarkTheme()
                                          ? Border.all(
                                              width: 1.0,
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                            )
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          headerTextStaking,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontSize: 16,
                                              ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          '${getAprOrApyFormat(lockState.stakingTokenModel!.apy!, 'APY')} / '
                                          '${getAprOrApyFormat(lockState.stakingTokenModel!.apr!, 'APR')}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          '5.55% Fee',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.3),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 7.17,
                                      bottom: 11.77,
                                      left: 3,
                                      right: 12.77,
                                    ),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF167156),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/staking_lock.svg',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                            ),
                          ),
                          child: StretchBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      titleText,
                                      style:
                                          Theme.of(context).textTheme.headline3,
                                    ),
                                  ],
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
                                            // Column(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.start,
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment.start,
                                            //   children: [
                                            //     InvestedField(
                                            //       label:
                                            //           // '${lockState.stakingModel!.rewardRoutes[0].label}',
                                            //           'Reinvest',
                                            //       tokenName:
                                            //           'DFI',
                                            //           // '${lockState.stakingModel!.rewardRoutes[0].targetAsset}',
                                            //       controller: controller,
                                            //       isDeleteBtn: false,
                                            //       isDisable: !isEdit,
                                            //     ),
                                            //   ],
                                            //
                                            // ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: AccentButton(
                                                label: 'Unstake',
                                                callback: () {
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context,
                                                              animation1,
                                                              animation2) =>
                                                          StakeUnstakeScreen(
                                                        isUnstake: true,
                                                      ),
                                                      transitionDuration:
                                                          Duration.zero,
                                                      reverseTransitionDuration:
                                                          Duration.zero,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            NewPrimaryButton(
                                              width: 140,
                                              title: 'Stake',
                                              callback: () {
                                                Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        StakeUnstakeScreen(
                                                      isUnstake: false,
                                                    ),
                                                    transitionDuration:
                                                        Duration.zero,
                                                    reverseTransitionDuration:
                                                        Duration.zero,
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        ),

                                      // if (isEdit)
                                      //   Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Container(
                                      //         width: 140,
                                      //         child: AccentButton(
                                      //           label: 'Cancel',
                                      //           callback: () {
                                      //             setState(() {
                                      //               isEdit = false;
                                      //             });
                                      //           },
                                      //         ),
                                      //       ),
                                      //       NewPrimaryButton(
                                      //         width: 140,
                                      //         title: 'Save',
                                      //         callback: () {
                                      //           setState(() {
                                      //             isEdit = false;
                                      //           });
                                      //         },
                                      //       )
                                      //     ],
                                      //   ),
                                    ],
                                  ),
                                ),
                                // if (lockState.isYieldMachine  && !isEdit) ...[
                                //   SizedBox(
                                //     height: 16,
                                //   ),
                                //   Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       SizedBox(
                                //         width: 156,
                                //         height: 43,
                                //         child: AccentButton(
                                //           label: 'Withdrawal',
                                //           callback: () {
                                //             if (lockState.availableBalances.length != 0) {
                                //               Navigator.push(
                                //                 context,
                                //                 PageRouteBuilder(
                                //                   pageBuilder: (context,
                                //                       animation1,
                                //                       animation2) =>
                                //                       YieldMachineActionScreen(
                                //                         isDeposit: false,
                                //                         isShowDepositAddress: lockState.availableBalances.length != 0,
                                //                       ),
                                //                   transitionDuration:
                                //                   Duration.zero,
                                //                   reverseTransitionDuration:
                                //                   Duration.zero,
                                //                 ),
                                //               );
                                //             } else {
                                //               showSnackBar(
                                //                 context,
                                //                 title: 'Insufficient funds',
                                //                 color: AppColors.txStatusError
                                //                     .withOpacity(0.1),
                                //                 prefix: Icon(
                                //                   Icons.close,
                                //                   color:
                                //                   AppColors.txStatusError,
                                //                 ),
                                //               );
                                //             }
                                //           },
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         width: 156,
                                //         height: 43,
                                //         child: NewPrimaryButton(
                                //           title: 'Deposit',
                                //           callback: () {
                                //             Navigator.push(
                                //               context,
                                //               PageRouteBuilder(
                                //                 pageBuilder: (context,
                                //                     animation1,
                                //                     animation2) =>
                                //                     YieldMachineActionScreen(
                                //                       isDeposit: true,
                                //                     ),
                                //                 transitionDuration:
                                //                 Duration.zero,
                                //                 reverseTransitionDuration:
                                //                 Duration.zero,
                                //               ),
                                //             );
                                //           },
                                //         ),
                                //       )
                                //     ],
                                //   ),
                                // ],
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

  String getAprOrApyFormat(double amount, String amountType) {
    return '${BalancesHelper().numberStyling(
      (amount * 100),
      fixed: true,
      fixedCount: 2,
    )}% $amountType';
  }
}
