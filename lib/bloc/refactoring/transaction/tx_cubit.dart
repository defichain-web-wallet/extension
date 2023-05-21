import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'tx_state.dart';

class TxCubit extends Cubit<TxState> {
  TxCubit() : super(TxState());

  init(context, TxType txType) async {
    try{
      emit(state.copyWith(status: TxStatusList.loading));
      final walletCubit = BlocProvider.of<WalletCubit>(context);
      var account = walletCubit.state.applicationModel!.activeAccount!;
      var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
      var balances = account.getPinnedBalances(activeNetwork);
      var activeBalance = balances.first;
      var token = activeBalance.token ?? activeBalance.lmPool;
      var availableBalance = await activeNetwork.getAvailableBalance(account: account, token: token!, type: txType);
      emit(state.copyWith(status: TxStatusList.success, balances: balances, activeBalance: activeBalance, availableBalance: availableBalance));
    } catch(e){
      emit(state.copyWith(status: TxStatusList.failure));
    }
  }

  changeActiveBalance(context, BalanceModel balanceModel, TxType txType) async {
    try{
      final walletCubit = BlocProvider.of<WalletCubit>(context);
      var account = walletCubit.state.applicationModel!.activeAccount!;
      var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
      var token = balanceModel.token ?? balanceModel.lmPool;
      var availableBalance = await activeNetwork.getAvailableBalance(account: account, token: token!, type: txType);
      emit(state.copyWith(status: TxStatusList.success, activeBalance: balanceModel, availableBalance: availableBalance));
    } catch(e){
      emit(state.copyWith(status: TxStatusList.failure));
    }
  }



  TxState get transactionState => state;

}
