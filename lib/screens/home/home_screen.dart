import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/rates/rates_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/home/widgets/asset_list.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/home/widgets/transaction_history.dart';
import 'package:defi_wallet/screens/tokens/add_token_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/home/home_sliver_app_bar.dart';
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

    transactionCubit.checkOngoingTransaction();

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
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    RatesCubit ratesCubit = BlocProvider.of<RatesCubit>(context);
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    if (widget.isLoadTokens) {
      tokensCubit.loadTokensFromStorage();
      ratesCubit.loadTokensFromStorage(walletCubit.state.activeNetwork);
      ratesCubit.loadRates(walletCubit.state.activeNetwork);
    }

    return BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
          return ScaffoldWrapper(
            isUpdate: true,
            builder: (
              BuildContext context,
              bool isFullScreen,
              TransactionState txState,
            ) {
                return Scaffold(
                  appBar: NewMainAppBar(
                    isShowLogo: true,
                  ),
                  drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                  endDrawer: AccountDrawer(
                    width: buttonSmallWidth,
                  ),
                  body: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, homeState) {
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
                            maxWidth: ScreenSizes.medium,
                            child: Stack(
                              children: [
                                ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(scrollbars: false),
                                  child: CustomScrollView(
                                    slivers: [
                                      HomeSliverAppBar(),
                                      SliverAppBar(
                                        backgroundColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        pinned: true,
                                        actions: [Container()],
                                        automaticallyImplyLeading: false,
                                        expandedHeight: 58.0,
                                        toolbarHeight: 58,
                                        flexibleSpace: FlexibleSpaceBar(
                                          background: Container(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                                right: 16,
                                                bottom: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: TabBarHeader(
                                                      tabController:
                                                          tabController,
                                                      currentTabIndex:
                                                          homeState.tabIndex,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  if (state.activeNetwork.isTokensPresent())
                                                    SizedBox(
                                                      width: 32,
                                                      height: 32,
                                                      child: NewActionButton(
                                                        iconPath:
                                                            'assets/icons/add_black.svg',
                                                        onPressed: () async {
                                                          await lockHelper
                                                              .provideWithLockChecker(
                                                            context,
                                                            () =>
                                                                Navigator.push(
                                                              context,
                                                              PageRouteBuilder(
                                                                pageBuilder: (context,
                                                                        animation1,
                                                                        animation2) =>
                                                                    AddTokenScreen(),
                                                                transitionDuration:
                                                                    Duration
                                                                        .zero,
                                                                reverseTransitionDuration:
                                                                    Duration
                                                                        .zero,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (tabController!.index == 0) ...[
                                        AssetList(),
                                        SliverFillRemaining(
                                          hasScrollBody: false,
                                          child: Container(
                                            height: txState
                                                    is! TransactionInitialState
                                                ? 90
                                                : 0,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        )
                                      ] else ...[
                                        TransactionHistory(),
                                        SliverFillRemaining(
                                          hasScrollBody: false,
                                          child: Container(
                                            height: txState
                                                    is! TransactionInitialState
                                                ? 90
                                                : 0,
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                                if (txState is! TransactionInitialState)
                                  TransactionStatusBar(key: txKey,),
                              ],
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
