import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_new_kyc_process_screen.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_select_verification_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class StakingKycStartScreen extends StatefulWidget {
  const StakingKycStartScreen({Key? key}) : super(key: key);

  @override
  State<StakingKycStartScreen> createState() => _StakingKycStartScreenState();
}

class _StakingKycStartScreenState extends State<StakingKycStartScreen>
    with ThemeMixin {
  final String stakingText = 'The custodial staking service powered by LOCK '
      'uses customers\' staked DFI, operates masternodes with it, '
      'and thus generates revenue (rewards) for customers.';
  final String titleText = 'Staking';
  FocusNode checkBoxFocusNode = FocusNode();
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (fiatContext, fiatState) {
            return BlocBuilder<LockCubit, LockState>(
              builder: (lockContext, lockState) {
                return Scaffold(
                  drawerScrimColor: Color(0x0f180245),
                  endDrawer: AccountDrawer(
                    width: buttonSmallWidth,
                  ),
                  appBar: NewMainAppBar(
                    bgColor: AppColors.viridian.withOpacity(0.16),
                    isShowLogo: false,
                  ),
                  body: Container(
                    decoration: BoxDecoration(
                        color: AppColors.viridian.withOpacity(0.16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 31,
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
                                    padding: EdgeInsets.only(
                                      top: 38,
                                      right: 18,
                                      left: 18,
                                      bottom: 43,
                                    ),
                                    width: 335,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color:
                                              AppColors.appSelectorBorderColor),
                                      color: isDarkTheme()
                                          ? DarkColors.scaffoldContainerBgColor
                                          : LightColors
                                              .scaffoldContainerBgColor,
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
                                          )}% '
                                          'APY / ${BalancesHelper().numberStyling(
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
                                          height: 12.8,
                                        ),
                                        Text(
                                          stakingText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                fontSize: 11.2,
                                              ),
                                          softWrap: true,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 26.2,
                                        ),
                                        Text(
                                          titleText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                fontSize: 19.2,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          width: 240,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/icons/check_green_icon.svg'),
                                                  SizedBox(
                                                    width: 6.4,
                                                  ),
                                                  Text(
                                                    'Stake DFI and earn up to '
                                                    '${lockState.lockAnalyticsDetails!.apy! * 100}% APY',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/icons/check_green_icon.svg'),
                                                  SizedBox(
                                                    width: 6.4,
                                                  ),
                                                  Text(
                                                    'Reinvest your rewards',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/icons/check_green_icon.svg'),
                                                  SizedBox(
                                                    width: 6.4,
                                                  ),
                                                  Text(
                                                    'Withdrawal at any time',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subtitle1!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
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
                            top: 24,
                            bottom: 24,
                            left: 16,
                            right: 16,
                          ),
                          width: double.infinity,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DefiCheckbox(
                                  callback: (val) {
                                    setState(() {
                                      isShow = val!;
                                    });
                                  },
                                  width: 190,
                                  value: isShow,
                                  focusNode: checkBoxFocusNode,
                                  isShowLabel: false,
                                  textWidget: Text(
                                    'Don´t show this guide next time',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                          fontSize: 10.4,
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .color!
                                              .withOpacity(0.8),
                                        ),
                                  ),
                                ),
                                SizedBox(height: 18),
                                NewPrimaryButton(
                                  callback: () {
                                    if (fiatState.kycStatus == 'Completed') {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              StakingSelectVerificationScreen(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              StakingNewKycProcessScreen(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      );
                                    }
                                  },
                                  title: 'Start KYC',
                                  width: buttonSmallWidth,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
