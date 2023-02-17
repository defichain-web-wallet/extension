import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen_new.dart';
import 'package:defi_wallet/screens/staking/kyc/staking_kyc_start_screen.dart';
import 'package:defi_wallet/screens/staking/staking_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class EarnScreenNew extends StatefulWidget {
  const EarnScreenNew({Key? key}) : super(key: key);

  @override
  State<EarnScreenNew> createState() => _EarnScreenNewState();
}

class _EarnScreenNewState extends State<EarnScreenNew> with ThemeMixin, SnackBarMixin {
  BalancesHelper balancesHelper = BalancesHelper();
  String titleText = 'Earn';
  int iterator = 0;

  @override
  void initState() {
    super.initState();
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    LockCubit lockCubit = BlocProvider.of<LockCubit>(context);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await fiatCubit.loadUserDetails(accountCubit.state.accounts!.first);
      await lockCubit.loadUserDetails(accountCubit.state.accounts!.first);
      await lockCubit.loadStakingDetails(accountCubit.state.accounts!.first);
      await lockCubit.loadAnalyticsDetails(accountCubit.state.accounts!.first);
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
        return BlocBuilder<AccountCubit, AccountState>(
            builder: (accountContext, accountState) {
          return BlocBuilder<LockCubit, LockState>(
              builder: (lockContext, lockState) {
            if (lockState.status == LockStatusList.success) {
              return BlocBuilder<TokensCubit, TokensState>(
                  builder: (tokensContext, tokensState) {
                double totalPairsBalance = 0;
                double totalPairsAPR = 0;
                String avaragePairsAPR = '';
                int countPairs = 0;

                String maxApr = TokensHelper()
                    .getAprFormat(getMaxAPR(tokensState.tokensPairs!), true);

                accountState.activeAccount!.balanceList!.forEach((element) {
                  if (element.isPair! && !element.isHidden!) {
                    countPairs += 1;
                    totalPairsAPR += getAPRbyPair(tokensState.tokensPairs!,element.token!);

                    var foundedAssetPair = List.from(tokensState.tokensPairs!
                        .where((item) => element.token == item.symbol))[0];

                    double baseBalance = element.balance! *
                        (1 / foundedAssetPair.totalLiquidityRaw) *
                        foundedAssetPair.reserveA!;
                    double quoteBalance = element.balance! *
                        (1 / foundedAssetPair.totalLiquidityRaw) *
                        foundedAssetPair.reserveB!;

                    totalPairsBalance += tokenHelper.getAmountByUsd(
                      tokensState.tokensPairs!,
                      baseBalance,
                      foundedAssetPair.tokenA,
                    );
                    totalPairsBalance += tokenHelper.getAmountByUsd(
                      tokensState.tokensPairs!,
                      quoteBalance,
                      foundedAssetPair.tokenB,
                    );
                  }
                });
                avaragePairsAPR =  TokensHelper().getAprFormat(countPairs > 0 ? totalPairsAPR/countPairs : 0, false);

                return Scaffold(
                  drawerScrimColor: Color(0x0f180245),
                  endDrawer: AccountDrawer(
                    width: buttonSmallWidth,
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
                                  style: headline2.copyWith(
                                      fontWeight: FontWeight.w700),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 19,
                            ),
                            GestureDetector(
                              onTap: () => stakingCallback(lockState),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 129,
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.portageBg
                                              .withOpacity(0.24),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 40,
                                                child: Image.asset(
                                                    'assets/images/dfi_staking.png'),
                                              ),
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Staking',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .copyWith(
                                                          fontSize: 16,
                                                        ),
                                                  ),
                                                  Text(
                                                    'up to '
                                                    '${BalancesHelper().numberStyling(
                                                      (lockState
                                                              .lockAnalyticsDetails!
                                                              .apy! *
                                                          100),
                                                      fixed: true,
                                                      fixedCount: 2,
                                                    )}% APY',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5!
                                                        .copyWith(
                                                          fontSize: 12,
                                                          color: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline5!
                                                              .color!
                                                              .withOpacity(0.3),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        if (lockState.lockStakingDetails != null)
                                                        Text(
                                                          lockState.lockUserDetails!
                                                                      .kycStatus! ==
                                                                  'Full'
                                                              ? balancesHelper
                                                                  .numberStyling(
                                                                  lockState
                                                                      .lockStakingDetails!
                                                                      .balance!,
                                                                  fixed: true,
                                                                  fixedCount: 2,
                                                                )
                                                              : '0.00',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline4!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        if (lockState.lockStakingDetails != null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 2.0),
                                                          child: Text(
                                                            lockState.lockUserDetails!
                                                                        .kycStatus! ==
                                                                    'Full'
                                                                ? lockState
                                                                    .lockStakingDetails!
                                                                    .asset!
                                                                : 'DFI',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline4!
                                                                .copyWith(
                                                                  fontSize: 13,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      'Staked',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5!
                                                          .copyWith(
                                                            fontSize: 12,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline5!
                                                                .color!
                                                                .withOpacity(
                                                                    0.3),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '0.00',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline4!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        20,
                                                                    color: AppColors
                                                                        .malachite,
                                                                  ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 2.0),
                                                          child: Text(
                                                            'DFI',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline4!
                                                                .copyWith(
                                                                  fontSize: 13,
                                                                  color: AppColors
                                                                      .malachite,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      'Rewards earned',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5!
                                                          .copyWith(
                                                            fontSize: 12,
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline5!
                                                                .color!
                                                                .withOpacity(
                                                                    0.3),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 1, top: 1),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                              left: 9,
                                              top: 11,
                                              right: 13,
                                              bottom: 13,
                                            ),
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF167156),
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(11),
                                                bottomLeft: Radius.circular(20),
                                              ),
                                            ),
                                            child: SvgPicture.asset(
                                                'assets/icons/staking_lock.svg'),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            GestureDetector(
                              onTap: () =>
                                  liquidityCallback(avaragePairsAPR, txState),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  width: double.infinity,
                                  height: 129,
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
                                        children: [
                                          Container(
                                            height: 40,
                                            child: Image.asset(
                                                'assets/pair_icons/dfi_btc.png'),
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Liquidity mining',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                      fontSize: 16,
                                                    ),
                                              ),
                                              Text(
                                                'up to ${maxApr} APR',
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
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      balancesHelper.numberStyling(totalPairsBalance/2, fixed: true),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline4!
                                                          .copyWith(
                                                            fontSize: 20,
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 2.0),
                                                      child: Text(
                                                        'USD',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline4!
                                                            .copyWith(
                                                              fontSize: 13,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  'Pooled',
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
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      avaragePairsAPR,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline4!
                                                          .copyWith(
                                                            fontSize: 20,
                                                            color: AppColors
                                                                .malachite,
                                                          ),
                                                    ),
                                                    countPairs > 0 ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 2.0),
                                                      child: Text(
                                                        '%',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline4!
                                                            .copyWith(
                                                              fontSize: 13,
                                                              color: AppColors
                                                                  .malachite,
                                                            ),
                                                      ),
                                                    ) : Container(),
                                                  ],
                                                ),
                                                Text(
                                                  'Portfolio APR',
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
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
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
          });
        });
      },
    );
  }

  double getMaxAPR(List<AssetPairModel> tokenPairs) {
    double maxValue = 0;

    tokenPairs.forEach((element) {
      if (maxValue < element.apr!) {
        maxValue = element.apr!;
      }
    });
    return maxValue;
  }

  double getAPRbyPair(List<AssetPairModel> tokenPairs, String pair) {
    double value = 0;

    tokenPairs.forEach((element) {
      if (pair == element.symbol) {
        value = element.apr!;
      }
    });
    return value;
  }

  stakingCallback(lockState) async{
    if (lockState.lockUserDetails.kycStatus == 'Full') {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => StakingScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      if (lockState.lockUserDetails.kycLink == 'https://kyc.lock.space?code=null'){
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        LockCubit lockCubit = BlocProvider.of<LockCubit>(context);
        await lockCubit.loadKycDetails(accountCubit.state.activeAccount!);
        await lockCubit.loadUserDetails(accountCubit.state.activeAccount!);
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

  liquidityCallback(String avaragePairsAPR, txState) {
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
