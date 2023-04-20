part of 'lock_cubit.dart';

enum LockStatusList { initial, loading, success, failure, expired }

enum LockStrategyList {
  Masternode,
  LiquidityMining;

  @override
  String toString() => this.name;
}

enum LockAssetCryptoCategory {
  Crypto,
  PoolPair,
  Stock;

  @override
  String toString() => this.name;
}

class LockState extends Equatable {
  final LockStatusList status;
  final LockStrategyList lockStrategy;
  final LockAssetCryptoCategory lockActiveAssetCategory;
  final LockUserModel? lockUserDetails;
  final LockStakingModel? lockStakingDetails;
  final LockAnalyticsModel? lockAnalyticsDetails;
  final LockRewardRoutesModel? lockRewardNewRoute;
  final List<LockAssetModel> lockAssets;
  final List<LockAssetModel> assetsByCategories;
  final int lastEditedRewardIndex;

  LockState({
    this.status = LockStatusList.initial,
    this.lockStrategy = LockStrategyList.Masternode,
    this.lockActiveAssetCategory = LockAssetCryptoCategory.Stock,
    this.lockUserDetails,
    this.lockStakingDetails,
    this.lockAnalyticsDetails,
    this.lockRewardNewRoute,
    this.lockAssets = const [],
    this.assetsByCategories = const [],
    this.lastEditedRewardIndex = 0,
  });

  @override
  List<Object?> get props => [
        status,
        lockStrategy,
        lockUserDetails,
        lockStakingDetails,
        lockAnalyticsDetails,
        lockRewardNewRoute,
        lockAssets,
        assetsByCategories,
        lastEditedRewardIndex,
      ];

  bool get isYieldMachine =>
      this.lockStrategy == LockStrategyList.LiquidityMining;

  List<LockBalanceModel> get availableBalances => lockStakingDetails!.balances!
      .where((element) =>
          element.balance! != 0 ||
          element.pendingDeposits != 0 ||
          element.pendingWithdrawals != 0)
      .toList();

  LockState copyWith({
    LockStatusList? status,
    LockStrategyList? lockStrategy,
    LockAssetCryptoCategory? lockActiveAssetCategory,
    LockUserModel? lockUserDetails,
    LockStakingModel? lockStakingDetails,
    LockAnalyticsModel? lockAnalyticsDetails,
    LockRewardRoutesModel? lockRewardNewRoute,
    List<LockAssetModel>? lockAssets,
    List<LockAssetModel>? assetsByCategories,
    int? lastEditedRewardIndex,
  }) {
    return LockState(
      status: status ?? this.status,
      lockStrategy: lockStrategy ?? this.lockStrategy,
      lockActiveAssetCategory:
          lockActiveAssetCategory ?? this.lockActiveAssetCategory,
      lockUserDetails: lockUserDetails ?? this.lockUserDetails,
      lockStakingDetails: lockStakingDetails ?? this.lockStakingDetails,
      lockAnalyticsDetails: lockAnalyticsDetails ?? this.lockAnalyticsDetails,
      lockRewardNewRoute: lockRewardNewRoute ?? this.lockRewardNewRoute,
      lockAssets: lockAssets ?? this.lockAssets,
      assetsByCategories: assetsByCategories ?? this.assetsByCategories,
      lastEditedRewardIndex: lastEditedRewardIndex ?? this.lastEditedRewardIndex,
    );
  }
}
