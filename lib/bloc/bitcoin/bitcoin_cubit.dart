import 'package:bloc/bloc.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/requests/btc_requests.dart';
import 'package:equatable/equatable.dart';

part 'bitcoin_state.dart';

class BitcoinCubit extends Cubit<BitcoinState> {
  BitcoinCubit() : super(BitcoinState());

  BtcRequests btcRequests = BtcRequests();

  loadDetails(AddressModel address) async {
    int balance;
    int availableBalance = 0;
    NetworkFeeModel networkFee;

    emit(state.copyWith(
        status: BitcoinStatusList.loading,
        totalBalance: state.totalBalance,
        availableBalance: state.availableBalance,
        networkFee: state.networkFee));

    try {
      balance = await btcRequests.getBalance(address: address);
      networkFee = await btcRequests.getNetworkFee();
      availableBalance = await btcRequests.getAvailableBalance(
        address: address,
        feePerByte: networkFee.low!,
      );

      emit(state.copyWith(
        status: BitcoinStatusList.success,
        totalBalance: balance,
        availableBalance: availableBalance,
        networkFee: networkFee,
      ));
    } catch (err) {
      emit(state.copyWith(
        status: BitcoinStatusList.failure,
        totalBalance: state.totalBalance,
        availableBalance: state.availableBalance,
        networkFee: state.networkFee,
      ));
    }
  }


}
