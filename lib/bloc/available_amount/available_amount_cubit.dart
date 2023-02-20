import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'available_amount_state.dart';

class AvailableAmountCubit extends Cubit<AvailableAmountState> {
  AvailableAmountCubit() : super(AvailableAmountState());

  getAvailable(String currency, TxType type, AccountModel account) async {
    emit(state.copyWith(
      status: AvailableAmountStatusList.loading,
      available: state.available,
      availableTo: state.availableTo,
      availableFrom: state.availableFrom,
    ));
    try {
      double res =
          await BalancesHelper().getAvailableBalance(currency, type, account);

      emit(state.copyWith(
        status: AvailableAmountStatusList.success,
        available: res,
        availableTo: state.availableTo,
        availableFrom: state.availableFrom,
      ));
    } catch(_) {
      print(_);
      emit(state.copyWith(
        status: AvailableAmountStatusList.failure,
        available: state.available,
        availableTo: state.availableTo,
        availableFrom: state.availableFrom,
      ));
    }
  }
  getAvailableTo(String currency, TxType type, AccountModel account) async {
    emit(state.copyWith(
      status: AvailableAmountStatusList.loading,
      available: state.available,
      availableTo: state.availableTo,
      availableFrom: state.availableFrom,
    ));
    try {
      double res =
          await BalancesHelper().getAvailableBalance(currency, type, account);

      emit(state.copyWith(
        status: AvailableAmountStatusList.success,
        available: state.available,
        availableTo: res,
        availableFrom: state.availableFrom,
      ));
    } catch(_) {
      print(_);
      emit(state.copyWith(
        status: AvailableAmountStatusList.failure,
        available: state.available,
        availableTo: state.availableTo,
        availableFrom: state.availableFrom,
      ));
    }
  }
  getAvailableFrom(String currency, TxType type, AccountModel account) async {
    emit(state.copyWith(
      status: AvailableAmountStatusList.loading,
      available: state.available,
      availableTo: state.availableTo,
      availableFrom: state.availableFrom,
    ));
    try {
      double res =
          await BalancesHelper().getAvailableBalance(currency, type, account);

      emit(state.copyWith(
        status: AvailableAmountStatusList.success,
        available: state.available,
        availableTo: state.availableTo,
        availableFrom: res,
      ));
    } catch(_) {
      print(_);
      emit(state.copyWith(
        status: AvailableAmountStatusList.failure,
        available: state.available,
        availableTo: state.availableTo,
        availableFrom: state.availableFrom,
      ));
    }
  }

}
