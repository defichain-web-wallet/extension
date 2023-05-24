part of 'home_cubit.dart';

enum HomeStatusList { show, hide }

class HomeState extends Equatable {
  final HomeStatusList status;
  final int tabIndex;
  final bool isShownHome;
  final Widget? scrollView;

  HomeState({
    this.status = HomeStatusList.show,
    this.tabIndex = 0,
    this.isShownHome = true,
    this.scrollView,
  });

  @override
  List<Object?> get props => [
    status,
    tabIndex,
    isShownHome,
    scrollView,
  ];

  HomeState copyWith({
    HomeStatusList? status,
    int? tabIndex = 0,
    bool? isShownHome,
    Widget? scrollView,
  }) {
    return HomeState(
      status: status ?? this.status,
      tabIndex: tabIndex ?? this.tabIndex,
      isShownHome: isShownHome ?? this.isShownHome,
      scrollView: scrollView ?? this.scrollView,
    );
  }
}