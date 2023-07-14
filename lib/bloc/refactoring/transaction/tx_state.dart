part of 'tx_cubit.dart';

enum TxStatusList { initial, loading, success, failure }

class TxState extends Equatable {
  final TxStatusList status;
  final List<BalanceModel>? balances;
  final double? availableBalance;
  final BalanceModel? activeBalance;
  final NetworkFeeModel? networkFee;
  final int activeFee;
  // final List<BalanceModel>? balances;

  TxState({
    this.status = TxStatusList.initial,
    this.balances,
    this.availableBalance,
    this.activeBalance,
    this.networkFee,
    this.activeFee = 0
  });

  TokenModel? get currentAsset => activeBalance!.lmPool ?? activeBalance!.token;

  @override
  List<Object?> get props => [
        status,
        balances,
    availableBalance,
    activeBalance,
    networkFee,
    activeFee,
      ];

  TxState copyWith({
    TxStatusList? status,
    List<BalanceModel>? balances,
    double? availableBalance,
    BalanceModel? activeBalance,
     NetworkFeeModel? networkFee,
     int? activeFee,
  }) {
    return TxState(
      status: status ?? this.status,
      balances: balances ?? this.balances,
      availableBalance: availableBalance ?? this.availableBalance,
      activeBalance: activeBalance ?? this.activeBalance,
      networkFee: networkFee ?? this.networkFee,
      activeFee: activeFee ?? this.activeFee,
    );
  }
}
