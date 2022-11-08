import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/liquidity/liquidity_header.dart';
import 'package:defi_wallet/widgets/liquidity/main_liquidity_pair.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_pool_list_screen.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiquidityScreen extends StatefulWidget {
  const LiquidityScreen({Key? key}) : super(key: key);

  @override
  _LiquidityScreenState createState() => _LiquidityScreenState();
}

class _LiquidityScreenState extends State<LiquidityScreen> {
  TokensHelper tokenHelper = TokensHelper();
  LockHelper lockHelper = LockHelper();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  void initState() {
    super.initState();
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    tokensCubit.loadTokens();
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

                  accountState.activeAccount!.balanceList!.forEach(
                    (element) {
                      if (!element.isHidden! && !element.isPair!) {
                        var balance = convertFromSatoshi(element.balance!);
                        totalTokensBalance += tokenHelper.getAmountByUsd(
                          tokensState.tokensPairs!,
                          balance,
                          element.token!,
                        );
                      } else if (element.isPair!) {
                        var foundedAssetPair = List.from(tokensState
                            .tokensPairs!
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
                    },
                  );

                  return Scaffold(
                    appBar: MainAppBar(
                        title: 'Liquidity',
                        isSmall: isFullScreen,
                        isShowBottom: !(txState is TransactionInitialState),
                        height: !(txState is TransactionInitialState)
                            ? toolbarHeightWithBottom
                            : toolbarHeight),
                    body: Container(
                      color: Theme.of(context).dialogBackgroundColor,
                      padding: AppTheme.screenPadding,
                      child: Center(
                        child: StretchBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (tokensPairsList.length != 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: LiquidityHeader(
                                    isBorder: isFullScreen,
                                    allAssetPairs: tokensState.tokensPairs,
                                    assetPairs: tokensPairsList,
                                    totalTokensBalance: totalTokensBalance,
                                    totalPairsBalance: totalPairsBalance,
                                  ),
                                ),
                              if (tokensPairsList.length != 0)
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

                                      return MainLiquidityPair(
                                        isBorder: isFullScreen,
                                        balance: tokensPairsList[index].balance,
                                        assetPair: tokenPairs,
                                      );
                                    },
                                  ),
                                )
                              else
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Not yet any asset pairs',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .apply(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    child: Text(
                                      ' +  Add liquidity ',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    onPressed: () async {
                                      await lockHelper.provideWithLockChecker(
                                        context,
                                        () => Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                LiquidityPoolListScreen(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
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
              },
            );
          },
        );
      },
    );
  }
}
