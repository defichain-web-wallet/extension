part of 'home_cubit.dart';

enum HomeStatusList { show, hide }

class HomeState extends Equatable {
  final HomeStatusList status;
  final int tabIndex;
  final String activeAsset;

  HomeState({
    this.status = HomeStatusList.show,
    this.tabIndex = 0,
    this.activeAsset = 'USD'
  });

  @override
  List<Object?> get props => [
    status,
    tabIndex,
    activeAsset
  ];

  HomeState copyWith({
    HomeStatusList? status,
    int? tabIndex = 0,
    String? activeAsset = 'USD'
  }) {
    return HomeState(
      status: status ?? this.status,
      tabIndex: tabIndex ?? this.tabIndex,
      activeAsset: activeAsset ?? this.activeAsset
    );
  }
}