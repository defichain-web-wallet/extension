part of 'home_cubit.dart';

enum HomeStatusList { show, hide }

class HomeState extends Equatable {
  final HomeStatusList status;
  final int tabIndex;
  final bool isShownHome;
  final bool isShowExtendedNetworkSelector;
  final bool isShowExtendedAccountDrawer;
  final Widget? scrollView;

  HomeState({
    this.status = HomeStatusList.show,
    this.tabIndex = 0,
    this.isShownHome = true,
    this.isShowExtendedNetworkSelector = true,
    this.isShowExtendedAccountDrawer = true,
    this.scrollView,
  });

  @override
  List<Object?> get props => [
    status,
    tabIndex,
    isShownHome,
    isShowExtendedNetworkSelector,
    isShowExtendedAccountDrawer,
    scrollView,
  ];

  HomeState copyWith({
    HomeStatusList? status,
    int? tabIndex = 0,
    bool? isShownHome,
    bool? isShowExtendedNetworkSelector,
    bool? isShowExtendedAccountDrawer,
    Widget? scrollView,
  }) {
    return HomeState(
      status: status ?? this.status,
      tabIndex: tabIndex ?? this.tabIndex,
      isShownHome: isShownHome ?? this.isShownHome,
      isShowExtendedNetworkSelector:
          isShowExtendedNetworkSelector ?? this.isShowExtendedNetworkSelector,
      isShowExtendedAccountDrawer:
          isShowExtendedAccountDrawer ?? this.isShowExtendedAccountDrawer,
      scrollView: scrollView ?? this.scrollView,
    );
  }
}