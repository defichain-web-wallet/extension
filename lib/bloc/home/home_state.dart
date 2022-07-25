part of 'home_cubit.dart';

enum HomeStatusList { show, hide }

class HomeState extends Equatable {
  final HomeStatusList status;

  HomeState({
    this.status = HomeStatusList.show,
  });

  @override
  List<Object?> get props => [
    status,
  ];

  HomeState copyWith({
    HomeStatusList? status,
  }) {
    return HomeState(
      status: status ?? this.status,
    );
  }
}