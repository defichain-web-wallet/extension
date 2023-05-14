part of 'bridge_cubit.dart';

enum BridgeStatusList { initial, loading, success, failure }

class BridgeState extends Equatable {
  final BridgeStatusList status;
  final BridgeModel? bridgeModel;

  BridgeState({
    this.status = BridgeStatusList.initial,
    this.bridgeModel,
  });

  @override
  List<Object?> get props => [
    status,
    bridgeModel,
  ];

  BridgeState copyWith({
    BridgeStatusList? status,
    BridgeModel? bridgeModel,
  }) {
    return BridgeState(
      status: status ?? this.status,
      bridgeModel: bridgeModel ?? this.bridgeModel,
    );
  }
}