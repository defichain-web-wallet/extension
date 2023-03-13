import 'dart:convert';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/requests/dex_requests.dart';
import 'package:defi_wallet/requests/token_requests.dart';
import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'tokens_state.dart';

class TokensCubit extends Cubit<TokensState> {
  TokensCubit() : super(TokensState());
  var tokensHelper = TokensHelper();

  loadTokens() async {
    emit(state.copyWith(
      status: TokensStatusList.loading,
    ));

    try {
      final tokens = await TokenRequests().getTokenList();
      final tokensDex = await DexRequests().getPoolPairs();
      final eurRate = await TokenRequests().getEurByUsdRate();

      emit(state.copyWith(
        status: TokensStatusList.success,
        tokens: tokens,
        maxAPR: TokensHelper().getMaxAPR(List.from(tokensDex[1])),
        foundTokens: List.from(tokens),
        tokensForSwap: tokensDex[0],
        tokensPairs: List.from(tokensDex[1]),
        eurRate: eurRate,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: TokensStatusList.failure,
      ));
    }
  }

  calculateEarnPage(context) async {
    print('sss');
    emit(state.copyWith(
      status: TokensStatusList.loading,
    ));
    var averageAccountAPR = calculateAverageAccountAPR(context);
    var totalPairsBalance =  calculateTotalPairsBalance(context);
    emit(state.copyWith(
      averageAccountAPR: averageAccountAPR,
      totalPairsBalance: totalPairsBalance,
      status: TokensStatusList.success,
    ));
  }

  double calculateAverageAccountAPR(context) {
    double totalPairsAPR = 0;
    int countPairs = 0;
    var accountState = BlocProvider.of<AccountCubit>(context).accountState;
    accountState.activeAccount!.balanceList!.forEach((element) {
      if (element.isPair! && !element.isHidden!) {
        countPairs += 1;
        totalPairsAPR +=
            TokensHelper().getAPRbyPair(state.tokensPairs!, element.token!);
      }});

    return countPairs > 0 ? totalPairsAPR / countPairs : 0;
  }

  //TODO: maybe need to create balance cubit
  double calculateTotalPairsBalance(context)  {
    double totalPairsBalance = 0;
    var accountState = BlocProvider.of<AccountCubit>(context).accountState;
    accountState.activeAccount!.balanceList!.forEach((element) {
      if (element.isPair! && !element.isHidden!) {
        var foundedAssetPair = List.from(state.tokensPairs!
            .where((item) => element.token == item.symbol))[0];

        double baseBalance = element.balance! *
            (1 / foundedAssetPair.totalLiquidityRaw) *
            foundedAssetPair.reserveA!;
        double quoteBalance = element.balance! *
            (1 / foundedAssetPair.totalLiquidityRaw) *
            foundedAssetPair.reserveB!;

        totalPairsBalance += tokenHelper.getAmountByUsd(
          state.tokensPairs!,
          baseBalance,
          foundedAssetPair.tokenA,
        );
        totalPairsBalance += tokenHelper.getAmountByUsd(
          state.tokensPairs!,
          quoteBalance,
          foundedAssetPair.tokenB,
        );
      }
    });

    return totalPairsBalance;
  }

  loadTokensFromStorage() async {
    emit(state.copyWith(
      status: TokensStatusList.loading,
    ));

    var boxrates = await Hive.openBox('rates');
    var tokensMainnet = await boxrates.get('tokensMainnet');
    var tokensTestnet = await boxrates.get('tokensTestnet');
    var poolpairsMainnet = await boxrates.get('poolpairsMainnet');
    var poolpairsTestnet = await boxrates.get('poolpairsTestnet');
    var rates = await boxrates.get('rates');
    await boxrates.close();

    if (tokensMainnet != null && poolpairsMainnet != null && rates != null) {
      final double eurRate = json.decode(rates["data"])["EUR"];
      late final tokens;
      late final tokensDex;

      if (SettingsHelper.settings.network! == 'mainnet') {
        tokens =
            await TokenRequests().getTokenList(json: tokensMainnet["data"]);
        tokensDex =
            await DexRequests().getPoolPairs(json: poolpairsMainnet["data"]);
      } else {
        tokens =
            await TokenRequests().getTokenList(json: tokensTestnet["data"]);
        tokensDex =
            await DexRequests().getPoolPairs(json: poolpairsTestnet["data"]);
      }

      try {
        emit(state.copyWith(
          status: TokensStatusList.success,
          tokens: tokens,
          foundTokens: List.from(tokens),
          tokensForSwap: tokensDex[0],
          tokensPairs: List.from(tokensDex[1]),
          eurRate: eurRate,
        ));
      } catch (err) {
        emit(state.copyWith(
          status: TokensStatusList.failure,
        ));
      }
    } else {
      await loadTokens();
    }
  }

  void search(tokens, value) {
    List<TokensModel> search = [];
    if (value == '') {
      emit(state.copyWith(
        status: TokensStatusList.success,
        tokens: state.tokens,
        foundTokens: List.from(tokens),
        tokensForSwap: state.tokensForSwap,
        tokensPairs: state.tokensPairs,
        eurRate: state.eurRate,
      ));
    } else {
      tokens.forEach((element) {
        if (element.symbol.contains(value.toUpperCase())) {
          search.add(element);
        } else if (element.symbol
            .contains(value.replaceAll('d', '').toUpperCase())) {
          search.add(element);
        }
      });
      emit(state.copyWith(
        status: TokensStatusList.success,
        tokens: state.tokens,
        foundTokens: search,
        tokensForSwap: state.tokensForSwap,
        tokensPairs: state.tokensPairs,
        eurRate: state.eurRate,
      ));
    }
  }
}
