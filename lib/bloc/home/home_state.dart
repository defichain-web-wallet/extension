part of 'home_cubit.dart';

enum HomeStatusList { show, hide }

class HomeState extends Equatable {
  final HomeStatusList status;
  final int tabIndex;

  HomeState({
    this.status = HomeStatusList.show,
    this.tabIndex = 0,
  });

  @override
  List<Object?> get props => [
    status,
    tabIndex,
  ];

  HomeState copyWith({
    HomeStatusList? status,
    int? tabIndex = 0,
  }) {
    return HomeState(
      status: status ?? this.status,
      tabIndex: tabIndex ?? this.tabIndex,
    );
  }
}