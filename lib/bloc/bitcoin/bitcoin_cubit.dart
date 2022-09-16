import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/requests/btc_requests.dart';
import 'package:equatable/equatable.dart';

part 'bitcoin_state.dart';

class BitcoinCubit extends Cubit<BitcoinState> {
  BitcoinCubit() : super(BitcoinState());

  BtcRequests btcRequests = BtcRequests();

  loadDetails(AddressModel address) async {
    int balance;
    List<dynamic> history;

    emit(state.copyWith(
      status: BitcoinStatusList.loading,
      totalBalance: state.totalBalance,
      availableBalance: state.availableBalance,
      activeFee: state.activeFee,
      networkFee: state.networkFee,
      history: state.history ?? [],
    ));

    try {
      balance = await btcRequests.getBalance(address: address);
      history = await btcRequests.getTransactionHistory(address: address);

      emit(state.copyWith(
        status: BitcoinStatusList.success,
        totalBalance: balance,
        availableBalance: state.availableBalance,
        activeFee: state.activeFee,
        networkFee: state.networkFee,
        history: history[0],
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BitcoinStatusList.failure,
        totalBalance: 0,
        availableBalance: 0,
        activeFee: 0,
        networkFee: state.networkFee,
        history: state.history ?? [],
      ));
    }
  }

  loadAvailableBalance(AddressModel address, {int? fee}) async {
    int availableBalance = 0;
    NetworkFeeModel networkFee;

    emit(state.copyWith(
      status: BitcoinStatusList.loading,
      totalBalance: state.totalBalance,
      availableBalance: state.availableBalance,
      activeFee: fee ?? state.activeFee,
      networkFee: state.networkFee,
      history: state.history ?? [],
    ));

    try {
      if (fee == null) {
        networkFee = await btcRequests.getNetworkFee();
      } else {
        networkFee = NetworkFeeModel(
          low: 0,
          medium: 1,
          high: 2,
        );
      }
      availableBalance = await btcRequests.getAvailableBalance(
          address: address, feePerByte: state.activeFee);

      emit(state.copyWith(
        status: BitcoinStatusList.success,
        totalBalance: state.totalBalance,
        availableBalance: availableBalance,
        activeFee: fee ?? networkFee.low,
        networkFee: networkFee,
        history: state.history ?? [],
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BitcoinStatusList.failure,
        totalBalance: state.totalBalance,
        availableBalance: state.availableBalance,
        activeFee: state.activeFee,
        networkFee: state.networkFee ??
            NetworkFeeModel(
              low: 0,
              medium: 1,
              high: 2,
            ),
        history: state.history ?? [],
      ));
    }
  }

  changeActiveFee(AddressModel address, int fee) async {
    int availableBalance = 0;
    try {
      availableBalance = await btcRequests.getAvailableBalance(
          address: address, feePerByte: fee);

      emit(state.copyWith(
        status: BitcoinStatusList.success,
        totalBalance: state.totalBalance,
        availableBalance: availableBalance,
        activeFee: fee,
        networkFee: state.networkFee,
        history: state.history ?? [],
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BitcoinStatusList.failure,
        totalBalance: state.totalBalance,
        availableBalance: state.availableBalance,
        activeFee: state.activeFee,
        networkFee: state.networkFee,
        history: state.history ?? [],
      ));
    }
  }

  sendTransaction(String tx) async {
    try {
      await btcRequests.sendTxHex(tx);
    } catch (err) {
      throw err;
    }
  }
}
