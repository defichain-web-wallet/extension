part of 'ramp_cubit.dart';

enum RampStatusList { initial, loading, success, expired, failure }

class RampState extends Equatable {
  final RampStatusList status;
  final DefichainRampModel? defichainRampModel;
  final RampUserModel? rampUserModel;

  RampState({
    this.status = RampStatusList.initial,
    this.defichainRampModel,
    this.rampUserModel,
  });

  @override
  List<Object?> get props => [
    status,
    defichainRampModel,
    rampUserModel
  ];

  RampState copyWith({
    RampStatusList? status,
    DefichainRampModel? defichainRampModel,
    RampUserModel? rampUserModel,
  }) {
    return RampState(
      status: status ?? this.status,
      defichainRampModel: defichainRampModel ?? this.defichainRampModel,
      rampUserModel: rampUserModel ?? this.rampUserModel,
    );
  }
}
