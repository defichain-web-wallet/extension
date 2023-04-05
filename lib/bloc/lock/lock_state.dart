part of 'lock_cubit.dart';

enum LockStatusList { initial, loading, success, failure, expired }

enum LockStrategyList {
  Masternode,
  LiquidityMining;

  @override
  String toString() => this.name;
}

class LockState extends Equatable {
  final LockStatusList status;
  final LockStrategyList lockStrategy;
  final LockUserModel? lockUserDetails;
  final LockStakingModel? lockStakingDetails;
  final LockAnalyticsModel? lockAnalyticsDetails;

  LockState({
    this.status = LockStatusList.initial,
    this.lockStrategy = LockStrategyList.Masternode,
    this.lockUserDetails,
    this.lockStakingDetails,
    this.lockAnalyticsDetails,
  });

  @override
  List<Object?> get props => [
        status,
        lockStrategy,
        lockUserDetails,
        lockStakingDetails,
        lockAnalyticsDetails,
      ];

  bool get isYieldMachine =>
      this.lockStrategy == LockStrategyList.LiquidityMining;

  List<LockBalanceModel> get availableBalances => lockStakingDetails!.balances!
      .where((element) => element.balance! != 0)
      .toList();

  LockState copyWith({
    LockStatusList? status,
    LockStrategyList? lockStrategy,
    LockUserModel? lockUserDetails,
    LockStakingModel? lockStakingDetails,
    LockAnalyticsModel? lockAnalyticsDetails,
  }) {
    return LockState(
      status: status ?? this.status,
      lockStrategy: lockStrategy ?? this.lockStrategy,
      lockUserDetails: lockUserDetails ?? this.lockUserDetails,
      lockStakingDetails: lockStakingDetails ?? this.lockStakingDetails,
      lockAnalyticsDetails: lockAnalyticsDetails ?? this.lockAnalyticsDetails,
    );
  }
}
