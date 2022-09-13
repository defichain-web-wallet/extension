import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/cancel_button.dart';
import 'package:defi_wallet/widgets/liquidity/pool_grid_list.dart';
import 'package:defi_wallet/widgets/liquidity/search_pool_pair_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiquidityPoolList extends StatefulWidget {
  @override
  _LiquidityPoolListState createState() => _LiquidityPoolListState();
}

class _LiquidityPoolListState extends State<LiquidityPoolList> {
  TextEditingController searchController = new TextEditingController();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) => BlocBuilder<TokensCubit, TokensState>(
              builder: (context, tokensState) => ScaffoldConstrainedBox(
                child: LayoutBuilder(builder: (context, constraints) {
                  TokensCubit tokensCubit =
                      BlocProvider.of<TokensCubit>(context);
                  if (tokensState.status == TokensStatusList.success) {
                    if (constraints.maxWidth < ScreenSizes.medium) {
                      return Scaffold(
                        appBar: MainAppBar(
                          customTitle: SearchPoolPairField(
                            controller: searchController,
                            tokensState: tokensState,
                          ),
                          isShowBottom: !(state is TransactionInitialState),
                          height: !(state is TransactionInitialState)
                              ? toolbarHeightWithBottom
                              : toolbarHeight,
                          action: CancelButton(callback: () {
                            tokensCubit.search(tokensState.tokens, '');
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        HomeScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }),
                        ),
                        body: _buildBody(context, tokensState),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: Scaffold(
                          appBar: MainAppBar(
                            customTitle: SearchPoolPairField(
                              controller: searchController,
                              tokensState: tokensState,
                            ),
                            action: CancelButton(callback: () {
                              tokensCubit.search(tokensState.tokens, '');
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          HomeScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            }),
                            isShowBottom: !(state is TransactionInitialState),
                            height: !(state is TransactionInitialState)
                                ? toolbarHeightWithBottom
                                : toolbarHeight,
                            isSmall: true,
                          ),
                          body: _buildBody(context, tokensState,
                              isFullSize: true),
                        ),
                      );
                    }
                  } else {
                    return Container();
                  }
                }),
              ),
            ));
  }

  Widget _buildBody(context, tokensState, {isFullSize = false}) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (accountContext, accountState) {
        if (accountState.status == AccountStatusList.success) {
          List<AssetPairModel> availableTokens = [];

          try {
            tokensState.tokensPairs.forEach((el) {
              var foundTokenPair = tokensState.foundTokens
                  .where((item) => item.isPair && el.symbol == item.symbol);
              var fountTokenPairList = List.from(foundTokenPair);
              if (fountTokenPairList.length == 1) {
                availableTokens.add(List.from(tokensState.tokensPairs.where(
                    (item) => item.symbol == fountTokenPairList[0].symbol))[0]);
              }
            });
          } catch (e) {
            print(e);
          }

          return Container(
            color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: isFullSize
                  ? StretchBox(
                      child: PoolGridList(
                        tokensPairs: availableTokens,
                        isFullSize: isFullSize,
                      ),
                      maxWidth: 700,
                    )
                  : StretchBox(
                      child: PoolGridList(
                        tokensPairs: availableTokens,
                        isFullSize: isFullSize,
                      ),
                    ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
