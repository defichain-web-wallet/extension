part of 'lock_cubit.dart';

enum LockStatusList { initial, loading, success, failure }

class LockState extends Equatable {
  final LockStatusList status;
  final LockUserModel? lockUserDetails;
  final LockStakingModel? lockStakingDetails;
  final LockAnalyticsModel? lockAnalyticsDetails;

  LockState({
    this.status = LockStatusList.initial,
    this.lockUserDetails,
    this.lockStakingDetails,
    this.lockAnalyticsDetails,
  });

  @override
  List<Object?> get props => [
        status,
        lockUserDetails,
        lockStakingDetails,
        lockAnalyticsDetails,
      ];

  LockState copyWith({
    LockStatusList? status,
    LockUserModel? lockUserDetails,
    LockStakingModel? lockStakingDetails,
    LockAnalyticsModel? lockAnalyticsDetails,
  }) {
    return LockState(
      status: status ?? this.status,
      lockUserDetails: lockUserDetails ?? this.lockUserDetails,
      lockStakingDetails: lockStakingDetails ?? this.lockStakingDetails,
      lockAnalyticsDetails: lockAnalyticsDetails ?? this.lockAnalyticsDetails,
    );
  }
}
