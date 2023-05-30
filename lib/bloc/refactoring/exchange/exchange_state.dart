part of 'exchange_cubit.dart';

enum ExchangeStatusList { initial, loading, success, failure }

class ExchangeState extends Equatable {
  ExchangeStatusList status;
  List<BalanceModel>? balances;
  List<BalanceModel>? secondInputBalances;
  List<ExchangePairModel>? availablePairs;
  List<ExchangePairModel>? selectedPairs;
  BalanceModel? selectedBalance;
  BalanceModel? selectedSecondInputBalance;
  double availableFrom;
  double availableTo;
  double amountFrom;
  double amountTo;
  double slippage;

  ExchangeState({
    this.status = ExchangeStatusList.initial,
    this.balances,
    this.availablePairs,
    this.selectedPairs,
    this.selectedBalance,
    this.secondInputBalances,
    this.selectedSecondInputBalance,
    this.availableFrom = 0,
    this.availableTo = 0,
    this.amountFrom = 0,
    this.amountTo = 0,
    this.slippage = 0.03,
  });

  @override
  List<Object?> get props => [
        status,
        balances,
        availablePairs,
        selectedPairs,
        selectedBalance,
        secondInputBalances,
        availableFrom,
        availableTo,
    selectedSecondInputBalance,
    amountFrom,
    amountTo,
    slippage
      ];

  ExchangeState copyWith(
      {ExchangeStatusList? status,
      List<BalanceModel>? balances,
      List<BalanceModel>? secondInputBalances,
      List<ExchangePairModel>? availablePairs,
      List<ExchangePairModel>? selectedPairs,
      BalanceModel? selectedBalance,
      BalanceModel? selectedSecondInputBalance,
      double? availableFrom,
      double? availableTo,
      double? amountFrom,
      double? amountTo,
      double? slippage,
      }) {
    return ExchangeState(
      status: status ?? this.status,
      balances: balances ?? this.balances,
      availablePairs: availablePairs ?? this.availablePairs,
      selectedPairs: selectedPairs ?? this.selectedPairs,
      selectedBalance: selectedBalance ?? this.selectedBalance,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      secondInputBalances: secondInputBalances ?? this.secondInputBalances,
      selectedSecondInputBalance: selectedSecondInputBalance ?? this.selectedSecondInputBalance,
      amountFrom: amountFrom ?? this.amountFrom,
      amountTo: amountTo ?? this.amountTo,
      slippage: slippage ?? this.slippage,
    );
  }
}
