part of 'home_cubit.dart';

enum HomeStatusList { show, hide }

class HomeState extends Equatable {
  final HomeStatusList status;
  final int tabIndex;
  final Widget? scrollView;

  HomeState({
    this.status = HomeStatusList.show,
    this.tabIndex = 0,
    this.scrollView,
  });

  @override
  List<Object?> get props => [
    status,
    tabIndex,
    scrollView,
  ];

  HomeState copyWith({
    HomeStatusList? status,
    int? tabIndex = 0,
    Widget? scrollView,
  }) {
    return HomeState(
      status: status ?? this.status,
      tabIndex: tabIndex ?? this.tabIndex,
      scrollView: scrollView ?? this.scrollView,
    );
  }
}