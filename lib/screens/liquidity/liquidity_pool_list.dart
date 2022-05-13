import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_state.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/liquidity/pool_grid_list.dart';
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
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: MainAppBar(
                  title: 'Select Pool Pair',
                  isShowBottom: !(state is TransactionInitialState),
                  height: !(state is TransactionInitialState)
                      ? toolbarHeightWithBottom
                      : toolbarHeight
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: MainAppBar(
                  title: 'Select Pool Pair',
                  action: null,
                  isShowBottom: !(state is TransactionInitialState),
                  height: !(state is TransactionInitialState)
                      ? toolbarHeightWithBottom
                      : toolbarHeight,
                  isSmall: true,
                ),
                body: _buildBody(context, isFullSize: true),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildBody(context, {isFullSize = false}) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (accountContext, accountState) {
        return BlocBuilder<TokensCubit, TokensState>(
            builder: (tokensContext, tokensState) {
          if (tokensState is TokensLoadedState &&
              accountState is AccountLoadedState) {
            return Container(
              color: Theme.of(context).dialogBackgroundColor,
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: isFullSize ? StretchBox(
                  child: PoolGridList(
                    tokensState: tokensState,
                    isFullSize: isFullSize,
                  ),
                  maxWidth: 700,
                ) : StretchBox(
                  child: PoolGridList(
                    tokensState: tokensState,
                    isFullSize: isFullSize,
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
      },
    );
  }
}
