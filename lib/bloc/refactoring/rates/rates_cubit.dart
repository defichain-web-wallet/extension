import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/rates/rates_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'rates_state.dart';

class RatesCubit extends Cubit<RatesState> {
  RatesCubit() : super(RatesState());

  setInitial() {
    emit(state.copyWith(
      status: RatesStatusList.initial,
    ));
  }

  updateActiveAsset(String asset) {
    emit(state.copyWith(
      activeAsset: asset,
    ));
  }

  loadRates(AbstractNetworkModel network) async {
    emit(state.copyWith(
      status: RatesStatusList.loading,
    ));

    RatesModel ratesModel = state.ratesModel ??
        RatesModel();

    try {
      await ratesModel.loadTokens(network);

      emit(state.copyWith(
        status: RatesStatusList.success,
        ratesModel: ratesModel,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: RatesStatusList.failure,
      ));
    }
  }

  searchTokens({
    String value = '',
    List<TokenModel> existingTokens = const [],
  }) {
    List<TokenModel> tokens = [];

    if (value.isEmpty) {
      tokens = state.ratesModel!.tokens!;
    } else {
      for (TokenModel element in state.ratesModel!.tokens!) {
        if (element.displaySymbol.toLowerCase().contains(value.toLowerCase())) {
          tokens.add(element);
        }
      }
    }
    if (existingTokens.isNotEmpty) {
      existingTokens.forEach((element) {
        tokens.removeWhere((token) => token.symbol == element.symbol);
      });
    }
    print(tokens);
    emit(state.copyWith(
      tokens: tokens,
    ));
  }
}
