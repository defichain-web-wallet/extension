part of 'lock_cubit.dart';

enum LockStatusList { initial, loading, success, failure }

class LockState extends Equatable {
  final LockStatusList status;
  final LockUserModel? lockUserDetails;
  final LockStakingModel? lockStakingDetails;

  LockState({
    this.status = LockStatusList.initial,
    this.lockUserDetails,
    this.lockStakingDetails,
  });

  @override
  List<Object?> get props => [
        status,
        lockUserDetails,
        lockStakingDetails,
      ];

  LockState copyWith({
    LockStatusList? status,
    LockUserModel? lockUserDetails,
    LockStakingModel? lockStakingDetails,
  }) {
    return LockState(
      status: status ?? this.status,
      lockUserDetails: lockUserDetails ?? this.lockUserDetails,
      lockStakingDetails: lockStakingDetails ?? this.lockStakingDetails,
    );
  }
}
