part of 'staking_cubit.dart';

enum StakingStatusList { initial, loading, success, restore, failure }

class StakingState extends Equatable {
  final StakingStatusList status;
  final int amount;

  StakingState({
    this.status = StakingStatusList.initial,
    this.amount = 0,
  });

  @override
  List<Object?> get props => [
    status,
    amount,
  ];

  StakingState copyWith({
    StakingStatusList? status,
    int? amount = 0,
  }) {
    return StakingState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
    );
  }
}