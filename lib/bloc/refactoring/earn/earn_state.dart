part of 'earn_cubit.dart';

enum EarnStatusList { initial, loading, success, restore, failure }

class EarnState extends Equatable {
  final EarnStatusList status;
  final List<AbstractLmProviderModel>? lmProviders;


  EarnState({
    this.status = EarnStatusList.initial,

    this.lmProviders,
  });

  @override
  List<Object?> get props => [
        status,
        lmProviders
      ];

  EarnState copyWith({
    EarnStatusList? status,
    List<AbstractLmProviderModel>? lmProviders,
  }) {
    return EarnState(
      status: status ?? this.status,
      lmProviders: lmProviders ?? this.lmProviders,

    );
  }
}
