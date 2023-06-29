import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/screens/liquidity/choose_pool_pair_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/liquidity/main_liquidity_pair.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/status_logo_and_title.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiquidityScreenNew extends StatefulWidget {
  final String totalBalance;
  final String investedBalance;

  const LiquidityScreenNew({
    Key? key,
    required this.totalBalance,
    required this.investedBalance,
  }) : super(key: key);

  @override
  State<LiquidityScreenNew> createState() => _LiquidityScreenNewState();
}

class _LiquidityScreenNewState extends State<LiquidityScreenNew>
    with ThemeMixin {
  TokensHelper tokenHelper = TokensHelper();
  LockHelper lockHelper = LockHelper();
  String titleText = 'Liquidity mining';
  LmPoolModel? currentAssetPair;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
              return BlocBuilder<LmCubit, LmState>(
                  builder: (lmContext, lmState) {
                if (lmState.status == LmStatusList.success) {
                  return Scaffold(
                    drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                    endDrawer: isFullScreen ? null : AccountDrawer(
                      width: buttonSmallWidth,
                    ),
                    appBar: isFullScreen ? null : NewMainAppBar(
                      isShowLogo: false,
                    ),
                    body: Container(
                      padding: EdgeInsets.only(
                        top: 22,
                        bottom: 0,
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
                          bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                          bottomRight: Radius.circular(isFullScreen ? 20 : 0),
                        ),
                      ),
                      child: Center(
                        child: StretchBox(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  PageTitle(
                                    title: titleText,
                                    isFullScreen: isFullScreen,
                                  ),
                                  Tooltip(
                                    margin: EdgeInsets.only(right: 9, top: 8),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkTheme()
                                          ? DarkColors.drawerBgColor
                                          : LightColors.drawerBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.lavenderPurple
                                            .withOpacity(0.32),
                                        width: 0.5,
                                      ),
                                    ),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .color!
                                              .withOpacity(0.5),
                                          fontSize: 10,
                                        ),
                                    message: 'Add liquidity pool',
                                    child: NewActionButton(
                                      isSvg: false,
                                      isStaticColor: true,
                                      bgGradient: gradientActionButtonBg,
                                      iconPath: 'assets/images/add_gradient.png',
                                      onPressed: () {
                                        NavigatorService.push(
                                          context,
                                          ChoosePoolPairScreen(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  right: 20,
                                  top: 16,
                                  bottom: 16,
                                  left: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDarkTheme()
                                        ? DarkColors
                                            .assetItemSelectorBorderColor
                                            .withOpacity(0.16)
                                        : LightColors
                                            .assetItemSelectorBorderColor
                                            .withOpacity(0.16),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDarkTheme()
                                      ? DarkColors.assetItemSelectorBorderColor
                                          .withOpacity(0.07)
                                      : LightColors.assetItemSelectorBorderColor
                                          .withOpacity(0.07),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [Text(
                                          lmState.averageApr!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3!
                                              .copyWith(
                                                color: AppColors.malachite,
                                                fontSize: 24,
                                              ),
                                        ), lmState.averageApr! != 'N/A' ? Text(
                                          ' %',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                            fontSize: 13,
                                            color: AppColors
                                                .malachite,
                                          ),
                                        ): Container()]),
                                        Text(
                                          'Portfolio APR',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .copyWith(
                                                fontSize: 10,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.5),
                                              ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 160,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total Balance',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                      fontSize: 10,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .headline5!
                                                          .color!
                                                          .withOpacity(0.5),
                                                    ),
                                              ),
                                              Text(
                                                '\$ ${widget.totalBalance}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Amount Invested',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2!
                                                    .copyWith(
                                                      fontSize: 10,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .headline5!
                                                          .color!
                                                          .withOpacity(0.5),
                                                    ),
                                              ),
                                              Text(
                                                '\$ ${widget.investedBalance}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
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
                              SizedBox(
                                height: 24,
                              ),
                              Expanded(
                                child: lmState.pairBalances!.length != 0
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: lmState.pairBalances!.length,
                                        itemBuilder: (context, index) {
                                          var tokenPairs =
                                          lmState.pairBalances![index];

                                          return Column(
                                            children: [
                                              MainLiquidityPair(
                                                isOpen: currentAssetPair ==
                                                    tokenPairs.lmPool!,
                                                balance: lmState.pairBalances![index]
                                                    .balance,
                                                assetPair: tokenPairs.lmPool!,
                                                callback: (currentPair) {
                                                  setState(() {
                                                    if (currentAssetPair !=
                                                        currentPair) {
                                                      currentAssetPair =
                                                          currentPair;
                                                    } else {
                                                      currentAssetPair = null;
                                                    }
                                                  });
                                                },
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : StatusLogoAndTitle(
                                        subtitle:
                                            'Jelly noticed you have no liquidity pools '
                                            'yet. Add a pool by clicking +',
                                        isTitlePosBefore: false,
                                  isSmall: true,
                                      ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    child: Center(
                      child: Loader(),
                    ),
                  );
                }
              });
            });
  }
}
