import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_fee_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/models/error/error_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/services/errors/sentry_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tx_state.dart';

class TxCubit extends Cubit<TxState> {
  TxCubit() : super(TxState());

  setInitial() {
    emit(state.copyWith(
        status: TxStatusList.initial));
  }

  init(context, TxType txType) async {
    try {
      emit(state.copyWith(status: TxStatusList.loading));
      final walletCubit = BlocProvider.of<WalletCubit>(context);
      var account = walletCubit.state.applicationModel!.activeAccount!;
      var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
      var balances = account.getPinnedBalances(activeNetwork);
      var activeBalance = balances.first;
      var token = activeBalance.token ?? activeBalance.lmPool;
      var availableBalance = await activeNetwork.getAvailableBalance(
          account: account, token: token!, type: txType);

      NetworkFeeModel? netwrokFee;
      int activeFee = 0;

      //TODO: move this to different function
      if (activeNetwork.networkType.networkName.name ==
              NetworkName.bitcoinMainnet.name ||
          activeNetwork.networkType.networkName.name ==
              NetworkName.bitcoinTestnet.name) {
        netwrokFee = await activeNetwork.getNetworkFee();
        activeFee = netwrokFee.low!;
      }
      emit(state.copyWith(
          status: TxStatusList.success,
          balances: balances,
          activeBalance: activeBalance,
          availableBalance: availableBalance,
          networkFee: netwrokFee,
          activeFee: activeFee));
    } catch (error, stackTrace) {
      SentryService.captureException(
        ErrorModel(
          file: 'tx_cubit.dart',
          method: 'init',
          exception: error.toString(),
        ),
        stackTrace: stackTrace,
      );
      emit(state.copyWith(status: TxStatusList.failure));
    }
  }

  changeActiveBalance(
    context,
    TxType txType, {
    BalanceModel? balanceModel,
    int? gasPrice,
    int? gasLimit,
  }) async {
    try {
      final walletCubit = BlocProvider.of<WalletCubit>(context);
      var account = walletCubit.state.applicationModel!.activeAccount!;
      var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
      var token;
      if (balanceModel == null) {
        token = state.activeBalance!.token;
      } else {
        token = balanceModel.token ?? balanceModel.lmPool;
      }
      var availableBalance;
      if (activeNetwork is EthereumNetworkModel) {
        availableBalance = await activeNetwork.getAvailableBalance(
          account: account,
          token: token!,
          type: txType,
          fee: EthereumNetworkFeeModel(
            gasPrice: gasPrice ?? 0,
            gasLimit: gasLimit ?? 0,
          ),
        );
      } else {
        availableBalance = await activeNetwork.getAvailableBalance(
          account: account,
          token: token!,
          type: txType,
        );
      }
      emit(state.copyWith(
          status: TxStatusList.success,
          activeBalance: balanceModel,
          availableBalance: availableBalance));
    } catch (error, stackTrace) {
      SentryService.captureException(
        ErrorModel(
          file: 'tx_cubit.dart',
          method: 'changeActiveBalance',
          exception: error.toString(),
        ),
        stackTrace: stackTrace,
      );
      emit(state.copyWith(status: TxStatusList.failure));
    }
  }

  changeActiveFee(int fee){
    emit(state.copyWith(
        activeFee: fee));
  }

  TxState get transactionState => state;
}
