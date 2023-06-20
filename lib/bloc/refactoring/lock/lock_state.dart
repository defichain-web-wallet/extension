part of 'lock_cubit.dart';

enum LockStatusList { initial, loading, success, notFound, neededKyc, expired, failure }

class LockState extends Equatable {
  final LockStatusList status;
  final List<AbstractStakingProviderModel>? stakingProviders;
  final AbstractStakingProviderModel? lockStaking;
  final AccessTokenModel? accessKey;
  final bool? lockAccountPresent;
  final bool? isKycDone;
  final String? kycLink;
  final StakingModel? stakingModel;
  final StakingTokenModel? stakingTokenModel;
  final double? availableBalance;


  LockState({
    this.status = LockStatusList.initial,
    this.availableBalance = 0,
    this.stakingProviders,
    this.lockStaking,
    this.accessKey,
    this.lockAccountPresent,
    this.isKycDone,
    this.kycLink,
    this.stakingModel,
    this.stakingTokenModel,
  });

  @override
  List<Object?> get props => [
        status,
    stakingProviders,
    lockStaking,
    accessKey,
    lockAccountPresent,
    isKycDone,
    kycLink,
    stakingModel,
    stakingTokenModel,
    availableBalance,
      ];

  LockState copyWith({
    LockStatusList? status,
    List<AbstractStakingProviderModel>? stakingProviders,
    AbstractStakingProviderModel? lockStaking,
    AccessTokenModel? accessKey,
    bool? lockAccountPresent,
    bool? isKycDone,
    String? kycLink,
    StakingModel? stakingModel,
    StakingTokenModel? stakingTokenModel,
    double? availableBalance,
  }) {
    return LockState(
      status: status ?? this.status,
      stakingProviders: stakingProviders ?? this.stakingProviders,
      lockStaking: lockStaking ?? this.lockStaking,
      accessKey: accessKey ?? this.accessKey,
      lockAccountPresent: lockAccountPresent ?? this.lockAccountPresent,
      isKycDone: isKycDone ?? this.isKycDone,
      kycLink: kycLink ?? this.kycLink,
      stakingModel: stakingModel ?? this.stakingModel,
      stakingTokenModel: stakingTokenModel ?? this.stakingTokenModel,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }
}
