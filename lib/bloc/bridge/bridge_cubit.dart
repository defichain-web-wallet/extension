import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bridge_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'bridge_state.dart';

class BridgeCubit extends Cubit<BridgeState> {
  BridgeCubit() : super(BridgeState());

  BitcoinNetworkModel bitcoinNetworkModel = BitcoinNetworkModel(
    NetworkTypeModel(
      networkName: NetworkName.defichainMainnet,
      networkString: 'defichainMainnet',
      isTestnet: false,
    ),
  );

  loadDetails(AddressModel address) async {
    int balance;
    List<HistoryModel> history;

    emit(state.copyWith(
      status: BridgeStatusList.loading,
    ));

    BridgeModel bridgeModel =
        state.bridgeModel ?? BridgeModel(bitcoinNetworkModel);

    try {
      balance = await bridgeModel.getBalance(
        bitcoinNetworkModel,
        address.address!,
      );

      history = await bridgeModel.getHistory(
        bitcoinNetworkModel,
        address.address!,
      );

      BridgeModel newBridgeModel = BridgeModel(
        bitcoinNetworkModel,
        totalBalance: balance,
        history: history,
      );

      emit(state.copyWith(
        status: BridgeStatusList.success,
        bridgeModel: newBridgeModel,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BridgeStatusList.failure,
      ));
    }
  }

  loadAvailableBalance(AddressModel address, {int? fee}) async {
    NetworkFeeModel networkFee;

    emit(state.copyWith(
      status: BridgeStatusList.loading,
    ));

    try {
      if (fee == null) {
        networkFee = await state.bridgeModel!.getNetworkFee(
          bitcoinNetworkModel,
        );
      } else {
        networkFee = NetworkFeeModel(
          low: 0,
          medium: 1,
          high: 2,
        );
      }
      await state.bridgeModel!.getAvailableBalance(
        bitcoinNetworkModel,
        address.address!,
        fee ?? 1,
      );

      BridgeModel newBridgeModel = BridgeModel(
        bitcoinNetworkModel,
        networkFeeModel: networkFee,
        history: state.bridgeModel!.history,
        totalBalance: state.bridgeModel!.totalBalance,
      );

      emit(state.copyWith(
        status: BridgeStatusList.success,
        bridgeModel: newBridgeModel,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BridgeStatusList.failure,
      ));
    }
  }

  changeActiveFee(AddressModel address, int fee) async {
    emit(state.copyWith(
      status: BridgeStatusList.loading,
    ));

    try {
      await state.bridgeModel!.getAvailableBalance(
        bitcoinNetworkModel,
        address.address!,
        fee,
      );

      emit(state.copyWith(
        status: BridgeStatusList.success,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BridgeStatusList.failure,
      ));
    }
  }

  Future<TxErrorModel> sendTransaction(String tx) async {
    try {
      return await state.bridgeModel!.send(bitcoinNetworkModel, tx);
    } catch (err) {
      return TxErrorModel(isError: true);
    }
  }
}
