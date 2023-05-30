import 'package:bloc/bloc.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'exchange_state.dart';

class ExchangeCubit extends Cubit<ExchangeState> {
  ExchangeCubit() : super(ExchangeState());

  setInitial(){
    emit(state.copyWith(status: ExchangeStatusList.initial));
  }

  init(context) async {
    emit(state.copyWith(status: ExchangeStatusList.loading));
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var balances = account.getPinnedBalances(activeNetwork);
    var exchanges = activeNetwork.getExchanges();
    var pairs = await exchanges.first.getAvailableExchangePairs(activeNetwork);
    emit(state.copyWith(
      balances: balances,
      availablePairs: pairs,
    ));

    await updateBalance(context, balances[0]);

    emit(state.copyWith(
      status: ExchangeStatusList.success,
    ));
  }
//assetFrom.symbol == 'DUSD' && assetTo!.symbol == 'DFI' slippage + 0.3
  updateAmountsAndSlipage({double? slippage, double? amountFrom, double? amountTo}){
    emit(state.copyWith(
      slippage: slippage,
      amountFrom: amountFrom,
      amountTo: amountTo,
    ));
  }

  updateBalanceTo(context, BalanceModel balance) async {
    emit(state.copyWith(
      selectedSecondInputBalance: balance,
    ));
  }

  calculateRate(TokenModel fromToken, TokenModel toToken, double amount){
    var pair = state.selectedPairs!.firstWhere((element) => (element.base.compare(fromToken) && element.quote.compare(toToken)) || (element.quote.compare(fromToken) && element.base.compare(toToken)));
    if(pair.base.compare(fromToken)){
      return amount * pair.ratio;
    } else {
      return amount * pair.ratioReverse;
    }
  }

  updateBalance(context, BalanceModel balance) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    
    var activePairs = state.availablePairs!
        .where((pair) =>
    pair.base.compare(balance.token!) ||
        pair.quote.compare(balance.token!))
        .toList();

    var secondInputBalances = _prepareSecondInputBalances(activePairs, balance);
    var selectedSecondInputBalance =  secondInputBalances[0];
    var availableBalance = await activeNetwork.getAvailableBalance(
        account: account, token: balance.token!, type: TxType.swap);

    emit(state.copyWith(
      selectedBalance: balance,
      selectedPairs: activePairs,
      availableFrom: availableBalance,
      secondInputBalances: secondInputBalances,
      selectedSecondInputBalance: selectedSecondInputBalance,
    ));
  }

  String getRateStringFormat(){
    ExchangePairModel pair = state.selectedPairs!.firstWhere((element) => (element.base.compare(state.selectedBalance!.token!) && element.quote.compare(state.selectedSecondInputBalance!.token!) || (element.base.compare(state.selectedSecondInputBalance!.token!) && element.quote.compare(state.selectedBalance!.token!))));
    var rate = pair.base.compare(state.selectedBalance!.token!) ? pair.ratioReverse : pair.ratio;
    return '1 ${state.selectedBalance!.token!.symbol} = ${rate.toStringAsFixed(8)} ${state.selectedSecondInputBalance!.token!.symbol}';
  }

  Future<TxErrorModel> exchange(context, password) async {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    var account = walletCubit.state.applicationModel!.activeAccount!;
    var activeNetwork = walletCubit.state.applicationModel!.activeNetwork!;
    var exchange = activeNetwork.getExchanges().first;
    var slipage = state.slippage;
    if(state.selectedBalance!.token!.symbol == 'DUSD' && state.selectedSecondInputBalance!.token!.symbol == 'DFI'){
      slipage = slipage + 0.3;
    }

    return exchange.exchange(account, activeNetwork, password, state.selectedBalance!.token!, state.amountFrom, state.amountTo, state.selectedSecondInputBalance!.token!, slipage, walletCubit.state.applicationModel!);
  }
  
  List<BalanceModel> _prepareSecondInputBalances(List<ExchangePairModel> pairs, BalanceModel selectedBalance){
    List<BalanceModel> balances = [];
    pairs.forEach((pair) {
      balances.add(BalanceModel(balance: 0, token:pair.base.compare(selectedBalance.token!) ? pair.quote : pair.base));
    });
    return balances;
  }

  ExchangeState get transactionState => state;
}
