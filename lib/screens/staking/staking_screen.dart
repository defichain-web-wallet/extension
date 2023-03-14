import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/staking/stake_unstake_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/app_tooltip.dart';
import 'package:defi_wallet/widgets/dialogs/staking_add_asset_dialog.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/fields/invested_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
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

class _StakingScreenState extends State<StakingScreen> with ThemeMixin {
  final String titleText = 'Staking';
  bool isEdit = false;
  bool isFirstBuild = true;
  TextEditingController controller = TextEditingController();
  late List<TextEditingController> controllers;
  late List<Widget> rewards;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        if (isFirstBuild) {
          AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
          LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
          lockCubit.loadStakingDetails(accountCubit.state.accounts!.first);
          isFirstBuild = false;
        }
        return BlocBuilder<LockCubit, LockState>(
          builder: (lockContext, lockState) {
            if (lockState.status == LockStatusList.success) {
              controller.text =
                  '${lockState.lockStakingDetails!.rewardRoutes![0].rewardPercent! * 100}';
              return Scaffold(
                drawerScrimColor: Color(0x0f180245),
                endDrawer: AccountDrawer(
                  width: buttonSmallWidth,
                ),
                appBar: NewMainAppBar(
                  bgColor: AppColors.viridian.withOpacity(0.16),
                  isShowLogo: false,
                  isShowNetworkSelector: false,
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
                                          : LightColors.scaffoldContainerBgColor,
                                      border: isDarkTheme()
                                          ? Border.all(
                                        width: 1.0,
                                        color: Colors.white.withOpacity(0.05),
                                      )
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'DFI Staking by LOCK',
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
                                          '${BalancesHelper().numberStyling(
                                            (lockState.lockAnalyticsDetails!
                                                    .apy! *
                                                100),
                                            fixed: true,
                                            fixedCount: 2,
                                          )}% APY / '
                                          '${BalancesHelper().numberStyling(
                                            (lockState.lockAnalyticsDetails!
                                                    .apr! *
                                                100),
                                            fixed: true,
                                            fixedCount: 2,
                                          )}% APR',
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
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${lockState.lockStakingDetails!.asset} Staking',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4!
                                                .copyWith(
                                                  fontSize: 16,
                                                ),
                                          ),
                                          Text(
                                            '${lockState.lockStakingDetails!.balance} ${lockState.lockStakingDetails!.asset}',
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
                                            '${lockState.lockStakingDetails!.pendingDeposits == 0 ? '' : '+'}'
                                            '${lockState.lockStakingDetails!.pendingDeposits}'
                                            ' ${lockState.lockStakingDetails!.asset}',
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
                                            '${lockState.lockStakingDetails!.pendingWithdrawals == 0 ? '' : '-'}'
                                            '${lockState.lockStakingDetails!.pendingWithdrawals}'
                                            ' ${lockState.lockStakingDetails!.asset}',
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
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  child: Center(
                                                    child: isEdit
                                                        ? NewActionButton(
                                                            isStaticColor: true,
                                                            bgGradient:
                                                                gradientActionButtonBg,
                                                            iconPath:
                                                                'assets/icons/add.svg',
                                                            onPressed: () {
                                                              showDialog(
                                                                barrierColor: Color(
                                                                    0x0f180245),
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return StakingAddAssetDialog();
                                                                },
                                                              );
                                                            },
                                                          )
                                                        : AppTooltip(
                                                          message: 'Coming soon',
                                                          margin: 0,
                                                          child: GestureDetector(
                                                              onTap: () {
                                                                // TODO: need to uncomment later
                                                                // setState(() {
                                                                //   isEdit = true;
                                                                // });
                                                              },
                                                              child: MouseRegion(
                                                                cursor:
                                                                    SystemMouseCursors
                                                                        .click,
                                                                child: SvgPicture
                                                                    .asset(
                                                                  'assets/icons/edit_gradient.svg',
                                                                  color: AppColors.grey,
                                                                ),
                                                              ),
                                                            ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 12,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InvestedField(
                                                  label:
                                                      '${lockState.lockStakingDetails!.rewardRoutes![0].label}',
                                                  tokenName:
                                                      '${lockState.lockStakingDetails!.rewardRoutes![0].targetAsset}',
                                                  controller: controller,
                                                  isDeleteBtn: false,
                                                  isDisable: !isEdit,
                                                ),
                                              ],
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
                                              callback: () {
                                                setState(() {
                                                  isEdit = false;
                                                });
                                              },
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
              return Container(
                child: Center(
                  child: ErrorPlaceholder(
                    description: 'Please check again later',
                    message: 'API is under maintenance',
                  ),
                ),
              );
            } else {
              return Loader();
            }
          },
        );
      },
    );
  }
}
