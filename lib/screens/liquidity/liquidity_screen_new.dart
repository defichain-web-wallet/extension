import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/choose_pool_pair_screen.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_pool_list.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/liquidity/main_liquidity_pair.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiquidityScreenNew extends StatefulWidget {
  const LiquidityScreenNew({Key? key}) : super(key: key);

  @override
  State<LiquidityScreenNew> createState() => _LiquidityScreenNewState();
}

class _LiquidityScreenNewState extends State<LiquidityScreenNew>
    with ThemeMixin {
  TokensHelper tokenHelper = TokensHelper();
  LockHelper lockHelper = LockHelper();
  String titleText = 'Liquidity mining';
  AssetPairModel? currentAssetPair;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<BitcoinCubit, BitcoinState>(
          builder: (context, bitcoinState) {
            return BlocBuilder<AccountCubit, AccountState>(
                builder: (accountContext, accountState) {
              return BlocBuilder<TokensCubit, TokensState>(
                  builder: (tokensContext, tokensState) {
                if (tokensState.status == TokensStatusList.success &&
                    accountState.status == AccountStatusList.success) {
                  var tokensPairs = accountState.activeAccount!.balanceList!
                      .where((element) =>
                          element.token!.contains(('-')) &&
                          element.balance! > 0);
                  var tokensPairsList = List.from(tokensPairs);

                  double totalTokensBalance = 0;
                  double totalPairsBalance = 0;

                  String asset = 'USD';
                  late double totalBalance;
                  late double unconfirmedBalance;
                  late double totalBalanceInFiat;

                  if (SettingsHelper.isBitcoin()) {
                    totalBalance =
                        convertFromSatoshi(bitcoinState.totalBalance);
                    unconfirmedBalance =
                        convertFromSatoshi(bitcoinState.unconfirmedBalance);
                  } else {
                    totalBalance = accountState.activeAccount!.balanceList!
                        .where((el) => !el.isHidden!)
                        .map<double>((e) {
                      if (!e.isPair!) {
                        if (asset == 'USD') {
                          return tokenHelper.getAmountByUsd(
                            tokensState.tokensPairs!,
                            convertFromSatoshi(e.balance!),
                            e.token!,
                          );
                        } else if (asset == 'EUR') {
                          var a = tokenHelper.getAmountByUsd(
                            tokensState.tokensPairs!,
                            convertFromSatoshi(e.balance!),
                            e.token!,
                          );
                          return a * tokensState.eurRate!;
                        } else {
                          return tokenHelper.getAmountByBtc(
                            tokensState.tokensPairs!,
                            convertFromSatoshi(e.balance!),
                            e.token!,
                          );
                        }
                      } else {
                        double balanceInSatoshi =
                            double.parse(e.balance!.toString());
                        if (asset == 'USD') {
                          return tokenHelper.getPairsAmountByAsset(
                              tokensState.tokensPairs!,
                              balanceInSatoshi,
                              e.token!,
                              'USD');
                        } else if (asset == 'EUR') {
                          var b = tokenHelper.getPairsAmountByAsset(
                              tokensState.tokensPairs!,
                              balanceInSatoshi,
                              e.token!,
                              'USD');
                          return b * tokensState.eurRate!;
                        } else {
                          return tokenHelper.getPairsAmountByAsset(
                              tokensState.tokensPairs!,
                              balanceInSatoshi,
                              e.token!,
                              'BTC');
                        }
                      }
                    }).reduce((value, element) => value + element);
                  }

                  accountState.activeAccount!.balanceList!.forEach((element) {
                    if (!element.isHidden! && !element.isPair!) {
                      var balance = convertFromSatoshi(element.balance!);
                      totalTokensBalance += tokenHelper.getAmountByUsd(
                        tokensState.tokensPairs!,
                        balance,
                        element.token!,
                      );
                    } else if (element.isPair!) {
                      var foundedAssetPair = List.from(tokensState.tokensPairs!
                          .where((item) => element.token == item.symbol))[0];

                      double baseBalance = element.balance! *
                          (1 / foundedAssetPair.totalLiquidityRaw) *
                          foundedAssetPair.reserveA!;
                      double quoteBalance = element.balance! *
                          (1 / foundedAssetPair.totalLiquidityRaw) *
                          foundedAssetPair.reserveB!;

                      totalTokensBalance += tokenHelper.getAmountByUsd(
                        tokensState.tokensPairs!,
                        baseBalance,
                        foundedAssetPair.tokenA,
                      );
                      totalTokensBalance += tokenHelper.getAmountByUsd(
                        tokensState.tokensPairs!,
                        quoteBalance,
                        foundedAssetPair.tokenB,
                      );

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
                                  Text(
                                    titleText,
                                    style: headline2.copyWith(
                                        fontWeight: FontWeight.w700),
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
                                        strokeAlign: StrokeAlign.center,
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
                                      isStaticColor: true,
                                      bgGradient: gradientActionButtonBg,
                                      iconPath: 'assets/icons/add.svg',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                ChoosePoolPairScreen(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
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
                                // height: 76,
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
                                        Text(
                                          '\$ 20.84',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3!
                                              .copyWith(
                                                color: AppColors.malachite,
                                                fontSize: 24,
                                              ),
                                        ),
                                        Text(
                                          'Current reward',
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
                                                '\$ ${balancesHelper.numberStyling(totalBalance, fixed: true)}',
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
                                                '\$ ${balancesHelper.numberStyling(totalPairsBalance, fixed: true)}',
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
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: tokensPairsList.length,
                                  itemBuilder: (context, index) {
                                    var foundedAssetPair = tokensState
                                        .tokensPairs!
                                        .where((element) =>
                                            tokensPairsList[index].token ==
                                            element.symbol);
                                    var tokenPairs =
                                        List.from(foundedAssetPair)[0];

                                    return Column(
                                      children: [
                                        MainLiquidityPair(
                                          isOpen:
                                              currentAssetPair == tokenPairs,
                                          balance:
                                              tokensPairsList[index].balance,
                                          assetPair: tokenPairs,
                                          callback: (currentPair) {
                                            setState(() {
                                              if (currentAssetPair !=
                                                  currentPair) {
                                                currentAssetPair = currentPair;
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
          },
        );
      },
    );
  }
}
