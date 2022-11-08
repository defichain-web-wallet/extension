import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/widgets/liquidity/pool_grid_list.dart';
import 'package:defi_wallet/widgets/liquidity/search_pool_pair_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiquidityPoolListScreen extends StatefulWidget {
  @override
  _LiquidityPoolListScreenState createState() =>
      _LiquidityPoolListScreenState();
}

class _LiquidityPoolListScreenState extends State<LiquidityPoolListScreen> {
  TextEditingController searchController = new TextEditingController();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<TokensCubit, TokensState>(
          builder: (context, tokensState) {
            return BlocBuilder<AccountCubit, AccountState>(
              builder: (accountContext, accountState) {
                if (accountState.status == AccountStatusList.success &&
                    tokensState.status == TokensStatusList.success) {
                  List<AssetPairModel> availableTokens = [];
                  try {
                    tokensState.tokensPairs!.forEach(
                      (el) {
                        var foundTokenPair = tokensState.foundTokens!.where(
                            (item) => item.isPair && el.symbol == item.symbol);
                        var fountTokenPairList = List.from(foundTokenPair);
                        if (fountTokenPairList.length == 1) {
                          availableTokens.add(List.from(tokensState.tokensPairs!
                              .where((item) =>
                                  item.symbol ==
                                  fountTokenPairList[0].symbol))[0]);
                        }
                      },
                    );
                  } catch (e) {
                    print(e);
                  }
                  return Scaffold(
                    appBar: MainAppBar(
                      customTitle: SearchPoolPairField(
                        controller: searchController,
                        tokensState: tokensState,
                      ),
                      isShowBottom: !(txState is TransactionInitialState),
                      height: !(txState is TransactionInitialState)
                          ? toolbarHeightWithBottom
                          : toolbarHeight,
                      isSmall: isFullScreen,
                    ),
                    body: Container(
                      color: Theme.of(context).dialogBackgroundColor,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: isFullScreen
                            ? StretchBox(
                                child: PoolGridList(
                                  tokensPairs: availableTokens,
                                  isFullSize: isFullScreen,
                                ),
                                maxWidth: 700,
                              )
                            : StretchBox(
                                child: PoolGridList(
                                  tokensPairs: availableTokens,
                                  isFullSize: isFullScreen,
                                ),
                              ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }
}
