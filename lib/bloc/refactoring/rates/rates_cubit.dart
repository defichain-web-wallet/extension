import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_rates_model.dart';
import 'package:defi_wallet/models/network/rates/rates_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/requests/defichain/asset/asset_requests.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'rates_state.dart';

class RatesCubit extends Cubit<RatesState> {
  RatesCubit() : super(RatesState());

  setInitial() {
    emit(state.copyWith(
      status: RatesStatusList.initial,
    ));
  }

  loadTokensFromStorage(AbstractNetworkModel network) async {
    emit(state.copyWith(
      status: RatesStatusList.loading,
    ));

    var boxrates = await Hive.openBox('rates');
    var tokensMainnet = await boxrates.get('tokensMainnet');
    var tokensTestnet = await boxrates.get('tokensTestnet');
    var poolpairsMainnet = await boxrates.get('poolpairsMainnet');
    var poolpairsTestnet = await boxrates.get('poolpairsTestnet');
    await boxrates.close();

    if (tokensMainnet != null && poolpairsMainnet != null) {
      late final tokens;
      late final poolPairs;

      if (network.networkType.isTestnet) {
        tokens = await AssetsRequests.getTokens(
          network,
          json: tokensTestnet["data"],
        );
        poolPairs = await AssetsRequests.getPoolPairs(
          network,
          json: poolpairsTestnet["data"],
        );
      } else {
        tokens = await AssetsRequests.getTokens(
          network,
          json: tokensMainnet["data"],
        );
        poolPairs = await AssetsRequests.getPoolPairs(
          network,
          json: poolpairsMainnet["data"],
        );
      }

      try {
        emit(state.copyWith(
          status: RatesStatusList.success,
          tokens: tokens,
          poolPairs: poolPairs,
        ));
      } catch (err) {
        emit(state.copyWith(
          status: RatesStatusList.failure,
        ));
      }
    } else {
      await loadTokens(network);
    }
  }

  loadTokens(AbstractNetworkModel network) async {
    emit(state.copyWith(
      status: RatesStatusList.loading,
    ));

    try {
      final tokens = await AssetsRequests.getTokens(network);
      final poolPairs = await AssetsRequests.getPoolPairs(network);

      emit(state.copyWith(
        status: RatesStatusList.success,
        tokens: tokens,
        poolPairs: poolPairs,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: RatesStatusList.failure,
      ));
    }
  }

  loadRates(AbstractNetworkModel network) async {
    emit(state.copyWith(
      status: RatesStatusList.loading,
    ));

    RatesModel ratesModel = state.ratesModel ??
        RatesModel();

    await ratesModel.loadTokens(network);

    emit(state.copyWith(
      status: RatesStatusList.success,
      ratesModel: ratesModel,
    ));
  }
}
