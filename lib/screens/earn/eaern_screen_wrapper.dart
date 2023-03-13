import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/access_token_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/earn/earn_card.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen_new.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_start_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EarnScreenWrapper extends StatefulWidget {
  final Function() loadEarnData;

  EarnScreenWrapper({
    Key? key,
    required this.loadEarnData,
  }) : super(key: key);

  @override
  State<EarnScreenWrapper> createState() => _EarnScreenWrapperState();
}

class _EarnScreenWrapperState extends State<EarnScreenWrapper> with ThemeMixin {
  final BalancesHelper balancesHelper = BalancesHelper();

  @override
  Widget build(BuildContext context) {
    String titleText = 'Earn';

    return Scaffold(
      drawerScrimColor: Color(0x0f180245),
      endDrawer: AccountDrawer(
        width: accountDrawerWidth,
      ),
      appBar: NewMainAppBar(
        isShowLogo: false,
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 22,
          bottom: 24,
          left: 16,
          right: 16,
        ),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDarkTheme()
              ? DarkColors.drawerBgColor
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
        child: Center(
          child: StretchBox(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.headline3!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 19,
                ),
                BlocBuilder<LockCubit, LockState>(
                    builder: (context, lockState) {
                  AccountCubit accountCubit =
                      BlocProvider.of<AccountCubit>(context);
                  var isLoading = lockState.status == LockStatusList.initial ||
                      lockState.status == LockStatusList.loading;
                  var isExpiredAccessToken =
                      lockState.status == LockStatusList.expired;
                  return stakingCard(
                    lockState,
                    accountCubit.state.accounts!.first.lockAccessToken ==
                            null ||
                        accountCubit
                            .state.accounts!.first.lockAccessToken!.isEmpty,
                    isLoading,
                    isExpiredAccessToken,
                  );
                }),
                SizedBox(
                  height: 18,
                ),
                BlocBuilder<TokensCubit, TokensState>(
                  builder: (tokensContext, tokensState) {
                    return liquidityMiningCard(
                      tokensState,
                      tokensState.status == TokensStatusList.loading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget liquidityMiningCard(
    TokensState tokensState,
    bool isLoading,
  ) {
    String avaragePairsAPR =
        TokensHelper().getAprFormat(tokensState.averageAccountAPR!, false);
    return EarnCard(
      isLoading: isLoading,
      title: 'Liquidity mining',
      subTitle:
          'up to ${TokensHelper().getAprFormat(tokensState.maxAPR!, true)} APR',
      imagePath: 'assets/pair_icons/dfi_btc.png',
      firstColumnNumber: balancesHelper
          .numberStyling(tokensState.totalPairsBalance!, fixed: true),
      firstColumnAsset: 'USD',
      firstColumnSubTitle: 'Pooled',
      secondColumnNumber: avaragePairsAPR,
      secondColumnAsset: '%',
      secondColumnSubTitle: 'Portfolio APR',
      isStaking: false,
      callback: () => liquidityCallback(avaragePairsAPR),
    );
  }

  Widget stakingCard(
    LockState lockState,
    bool isEmptyToken,
    bool isLoading,
    bool isExpiredAccessToken,
  ) {
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
                ? balancesHelper.numberStyling(
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
        needUpdateAccessToken: isEmptyToken || isExpiredAccessToken,
        errorMessage: 'Need to create account of LOCK',
        callback: () {
          if (isEmptyToken || isExpiredAccessToken) {
            var needDfxToken =
                accountCubit.state.accounts!.first.accessToken == null ||
                    accountCubit.state.accounts!.first.accessToken!.isEmpty;
            AccessTokenHelper.setupLockAccessToken(
              context,
              widget.loadEarnData,
              needUpdateDfx: needDfxToken || isExpiredAccessToken,
              dialogMessage: 'Please entering your password for create account',
            );
          } else {
            if (!isLoading) {
              stakingCallback();
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
          await AccessTokenHelper.setupLockAccessToken(
              context, widget.loadEarnData,
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
  }

  stakingCallback() async {
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
    if (lockCubit.checkVerifiedUser(isCheckOnlyKycStatus: true)) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => StakingScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      if (lockCubit.checkValidKycLink()) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
        await lockCubit.loadKycDetails(accountCubit.state.accounts!.first);
        await lockCubit.loadUserDetails(accountCubit.state.accounts!.first);
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              StakingKycStartScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  liquidityCallback(String avaragePairsAPR) {
    Widget redirectTo = LiquidityScreenNew(averageARP: avaragePairsAPR);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => redirectTo,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
