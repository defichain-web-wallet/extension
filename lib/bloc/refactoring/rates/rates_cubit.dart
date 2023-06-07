import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/rates/rates_model.dart';
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
}
