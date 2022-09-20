part of 'bitcoin_cubit.dart';

enum BitcoinStatusList { initial, loading, success, failure }

class BitcoinState extends Equatable {
  final BitcoinStatusList status;
  final int totalBalance;
  final int unconfirmedBalance;
  final int availableBalance;
  final int activeFee;
  final NetworkFeeModel? networkFee;
  final List<HistoryModel>? history;

  BitcoinState({
    this.status = BitcoinStatusList.initial,
    this.totalBalance = 0,
    this.unconfirmedBalance = 0,
    this.availableBalance = 0,
    this.activeFee = 0,
    this.networkFee,
    this.history,
  });

  BitcoinState copyWith({
    BitcoinStatusList? status,
    int? totalBalance,
    int? unconfirmedBalance,
    int? availableBalance,
    int? activeFee,
    NetworkFeeModel? networkFee,
    List<HistoryModel>? history,
  }) {
    return BitcoinState(
      status: status ?? this.status,
      totalBalance: totalBalance ?? this.totalBalance,
      unconfirmedBalance: unconfirmedBalance ?? this.unconfirmedBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      activeFee: activeFee ?? this.activeFee,
      networkFee: networkFee ?? this.networkFee,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
    status,
    totalBalance,
    unconfirmedBalance,
    availableBalance,
    activeFee,
    networkFee,
    history,
  ];
}
