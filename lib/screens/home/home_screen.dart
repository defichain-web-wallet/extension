import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_network_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/home/home_extended_view.dart';
import 'package:defi_wallet/widgets/home/home_tabs_scroll_view.dart';
import 'package:defi_wallet/widgets/home/transaction_status_bar.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final bool isLoadTokens;
  final String snackBarMessage;

  const HomeScreen({
    Key? key,
    this.isLoadTokens = false,
    this.snackBarMessage = '',
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SnackBarMixin, ThemeMixin, TickerProviderStateMixin {
  static const int timerDuration = 30;
  static const double extendedBoxWidth = 1440 - 32;
  static const double extendedFirstColumnWidth = 328;
  static const double extendedLastColumnWidth = 488;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? timer;
  TabController? tabController;
  LockHelper lockHelper = LockHelper();
  bool isShownSnackBar = false;
  double sliverTopHeight = 0.0;
  double targetSliverTopHeight = 76.0;
  GlobalKey txKey = GlobalKey();

  tabListener() {
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);
    homeCubit.updateTabIndex(index: tabController!.index);
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    );
    tabController!.addListener(tabListener);
    TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    transactionCubit.checkOngoingTransaction(
      walletCubit.state.activeNetwork.networkType,
    );

    lockHelper.updateTimer();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RatesCubit ratesCubit = BlocProvider.of<RatesCubit>(context);
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    if (widget.isLoadTokens) {
      ratesCubit.loadRates(walletCubit.state.activeNetwork);
    }
    if (walletCubit.state.isSendReceiveOnly &&
        walletCubit.state.activeNetwork is! EthereumNetworkModel) {
      walletCubit.updateAccountBalances();
    }

    return BlocBuilder<WalletCubit, WalletState>(builder: (context, walletState) {
          return ScaffoldWrapper(
            isUpdate: true,
            builder: (
              BuildContext context,
              bool isFullScreen,
              TransactionState txState,
            ) {
                return Scaffold(
                  key: _scaffoldKey,
                  appBar: NewMainAppBar(
                    isShowLogo: true,
                  ),
                  drawerScrimColor: isFullScreen
                      ? Colors.transparent
                      : AppColors.tolopea.withOpacity(0.06),
                  endDrawer: AccountDrawer(
                    width: isFullScreen ? 298 : buttonSmallWidth,
                  ),
                  body: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, homeState) {
                      if (timer == null) {
                        timer = Timer.periodic(
                          Duration(seconds: timerDuration),
                          (timer) async => walletCubit.updateAccountBalances(),
                        );
                      }
                      if (widget.snackBarMessage.isNotEmpty &&
                          !isShownSnackBar) {
                        Future<Null>.delayed(Duration.zero, () {
                          showSnackBar(context, title: widget.snackBarMessage);
                        });
                        isShownSnackBar = true;
                      }
                      return Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Center(
                          child: StretchBox(
                            maxWidth: extendedBoxWidth,
                            child: Container(
                              padding: EdgeInsets.only(bottom: isFullScreen ? 36 : 0),
                              child: Stack(
                                children: [
                                  if (isFullScreen)
                                    HomeExtendedView(
                                      firstColumnWidth:
                                          extendedFirstColumnWidth,
                                      lastColumnWidth: extendedLastColumnWidth,
                                      txState: txState,
                                      tabController: tabController!,
                                    )
                                  else
                                    HomeTabsScrollView(
                                      txState: txState,
                                      tabController: tabController!,
                                      activeTabIndex: homeState.tabIndex,
                                      isShowHomeCard: true,
                                    ),
                                  if (txState is! TransactionInitialState && !walletState.isSendReceiveOnly)
                                    TransactionStatusBar(
                                      key: txKey,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );

            },
          );
    });
  }
}
