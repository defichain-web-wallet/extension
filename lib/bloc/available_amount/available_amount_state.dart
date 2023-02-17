part of 'available_amount_cubit.dart';

enum AvailableAmountStatusList { initial, loading, success, failure }

class AvailableAmountState extends Equatable {
  final AvailableAmountStatusList status;
  final double? available;
  final double? availableTo;
  final double? availableFrom;


  AvailableAmountState({
    this.status = AvailableAmountStatusList.initial,
    this.available,
    this.availableTo,
    this.availableFrom,
  });

  @override
  List<Object?> get props => [
    status,
    available,
    availableTo,
    availableFrom,
  ];

  AvailableAmountState copyWith({
    final AvailableAmountStatusList? status,
    double? available,
    double? availableTo,
    double? availableFrom,
  }) {
    return AvailableAmountState(
      status: status ?? this.status,
      available: available ?? this.available,
      availableTo: availableTo ?? this.availableTo,
      availableFrom: availableFrom ?? this.availableFrom,
    );
  }
}