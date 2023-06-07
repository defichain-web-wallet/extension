part of 'rates_cubit.dart';

enum RatesStatusList { initial, loading, success, failure }

class RatesState extends Equatable {
  final RatesStatusList status;
  final RatesModel? ratesModel;

  RatesState({
    this.status = RatesStatusList.initial,
    this.ratesModel,
  });

  @override
  List<Object?> get props => [
        status,
        ratesModel,
      ];

  RatesState copyWith({
    RatesStatusList? status,
    RatesModel? ratesModel,
  }) {
    return RatesState(
      status: status ?? this.status,
      ratesModel: ratesModel ?? this.ratesModel,
    );
  }
}
