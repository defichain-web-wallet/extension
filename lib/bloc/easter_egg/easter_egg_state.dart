part of 'easter_egg_cubit.dart';


enum EasterEggStatusList { initial, loading, success, failure }

class EasterEggState extends Equatable {
  final EasterEggStatusList status;
  final EasterEggModel? eggsStatus;

  EasterEggState({
    this.status = EasterEggStatusList.initial,
    this.eggsStatus,
  });

  @override
  List<Object?> get props =>
      [
        status,
        eggsStatus,
      ];

  EasterEggState copyWith({
    EasterEggStatusList? status,
    EasterEggModel? eggsStatus,
  }) {
    return EasterEggState(
      status: status ?? this.status,
      eggsStatus: eggsStatus ?? this.eggsStatus,
    );
  }
}
