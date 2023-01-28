part of 'lock_cubit.dart';

enum LockStatusList { initial, loading, success, failure }

class LockState extends Equatable {
  final LockStatusList status;
  final LockUserModel? lockUserDetails;

  LockState({
    this.status = LockStatusList.initial,
    this.lockUserDetails,
  });

  @override
  List<Object?> get props => [
        status,
        lockUserDetails,
      ];

  LockState copyWith({
    LockStatusList? status,
    LockUserModel? lockUserDetails,
  }) {
    return LockState(
      status: status ?? this.status,
      lockUserDetails: lockUserDetails ?? this.lockUserDetails,
    );
  }
}
