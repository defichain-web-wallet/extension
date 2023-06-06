import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
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
        builder: (context, state) => ScaffoldConstrainedBox(
                child: LayoutBuilder(builder: (context, constraints) {
                  LmCubit lmCubit =
                      BlocProvider.of<LmCubit>(context);
                    if (constraints.maxWidth < ScreenSizes.medium) {
                      return Scaffold(
                        appBar: MainAppBar(
                          customTitle: SearchPoolPairField(
                            controller: searchController,
                          ),
                          isShowBottom: !(state is TransactionInitialState),
                          height: !(state is TransactionInitialState)
                              ? toolbarHeightWithBottom
                              : toolbarHeight,
                          action: CancelButton(callback: () {
                            lmCubit.search( '');
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
                        body: _buildBody(context),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: Scaffold(
                          appBar: MainAppBar(
                            customTitle: SearchPoolPairField(
                              controller: searchController,
                            ),
                            action: CancelButton(callback: () {
                              lmCubit.search('');
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
                          body: _buildBody(context,
                              isFullSize: true),
                        ),
                      );
                    }
                  }),
                ));
  }

  Widget _buildBody(context, {isFullSize = false}) {
    return BlocBuilder<LmCubit, LmState>(
      builder: (lmContext, lmState) {
        if (lmState.status == LmStatusList.success) {

          return Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: const EdgeInsets.only(bottom: 24),
            child: Center(
              child: isFullSize
                  ? StretchBox(
                      child: PoolGridList(
                        tokensPairs: lmState.foundedPools,
                        isFullSize: isFullSize,
                      ),
                      maxWidth: 700,
                    )
                  : StretchBox(
                      child: PoolGridList(
                        tokensPairs: lmState.foundedPools,
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
