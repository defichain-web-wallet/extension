import 'dart:developer';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/home/widgets/asset_list.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_body.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/home/widgets/transaction_history.dart';
import 'package:defi_wallet/screens/liquidity/earn_screen_new.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/buy_sell_screen.dart';
import 'package:defi_wallet/screens/tokens/add_token_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/common/app_tooltip.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/home/account_balance.dart';
import 'package:defi_wallet/widgets/home/home_card.dart';
import 'package:defi_wallet/widgets/home/home_sliver_app_bar.dart';
import 'package:defi_wallet/widgets/home/transaction_status_bar.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';

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
  static const int tickerTimerUpdate = 15;
  Timer? timer;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;
  bool isSaveOpenTime = false;
  LockHelper lockHelper = LockHelper();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  bool isFullSizeScreen = false;
  double assetsTabBodyHeight = 0;
  double historyTabBodyHeight = 0;
  double minDefaultTabBodyHeight = 255;
  double maxDefaultTabBodyHeight = 475;
  double maxHistoryEntries = 30;
  double heightListEntry = 74;
  double heightAdditionalAction = 60;
  bool isShownSnackBar = false;
  double sliverTopHeight = 0.0;
  double targetSliverTopHeight = 76.0;

  tabListener() {
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);
    homeCubit.updateTabIndex(index: tabController!.index);
  }

  setTabBody({int tabIndex = 0}) {
    AccountState accountState = BlocProvider.of<AccountCubit>(context).state;
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    double countAssets = 0;
    double countTransactions = 0;

    // TODO(eth): use the specific network's interface
    if (SettingsHelper.isBitcoin()) {
      late List<dynamic> tempHistoryList;
      countAssets = 1;
      tempHistoryList = bitcoinCubit.state.history ?? [];
      countTransactions = tempHistoryList.length.toDouble();
      bitcoinCubit.loadDetails(accountState.activeAccount!.bitcoinAddress!);
    } else {
      countAssets = accountState.activeAccount!.balanceList!
          .where((el) => !el.isHidden!)
          .length
          .toDouble();
      countTransactions =
          accountState.activeAccount!.historyList!.length.toDouble();
    }
    assetsTabBodyHeight =
        countAssets * heightListEntry + heightAdditionalAction;

    if (countTransactions < maxHistoryEntries) {
      historyTabBodyHeight =
          countTransactions * heightListEntry + heightAdditionalAction;
    } else {
      historyTabBodyHeight =
          maxHistoryEntries * heightListEntry + heightAdditionalAction;
    }

    if (isFullSizeScreen) {
      if (assetsTabBodyHeight < maxDefaultTabBodyHeight) {
        assetsTabBodyHeight = maxDefaultTabBodyHeight;
      }

      if (historyTabBodyHeight < maxDefaultTabBodyHeight) {
        historyTabBodyHeight = maxDefaultTabBodyHeight;
      }
    } else {
      if (assetsTabBodyHeight < minDefaultTabBodyHeight) {
        assetsTabBodyHeight = minDefaultTabBodyHeight;
      }

      if (historyTabBodyHeight < minDefaultTabBodyHeight) {
        historyTabBodyHeight = minDefaultTabBodyHeight;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setTabBody();
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
    tabController!.dispose();
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    if (widget.isLoadTokens) {
      tokensCubit.loadTokensFromStorage();
    }

    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          return ScaffoldWrapper(
            isUpdate: true,
            builder: (
              BuildContext context,
              bool isFullScreen,
              TransactionState txState,
            ) {
              if (state.status == AccountStatusList.loading ||
                  tokensState.status == TokensStatusList.loading) {
                return Container(
                  child: Center(
                    child: Loader(),
                  ),
                );
              } else if (tokensState.status == TokensStatusList.failure) {
                return Container(
                  child: Center(
                    child: ErrorPlaceholder(
                      message: 'API error',
                      description:
                          'Please change the API on settings and try again',
                    ),
                  ),
                );
              } else {
                return Scaffold(
                  appBar: NewMainAppBar(
                    isShowLogo: true,
                  ),
                  drawerScrimColor: Color(0x0f180245),
                  endDrawer: AccountDrawer(
                    width: buttonSmallWidth,
                  ),
                  body: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, homeState) {
                      if (timer == null) {
                        timer =
                            Timer.periodic(Duration(seconds: tickerTimerUpdate),
                                (timer) async {
                          await accountCubit.loadAccounts();
                        });
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
                                                  if (!SettingsHelper
                                                      .isBitcoin())
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
                                  TransactionStatusBar(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      );
    });
  }

  bool isExistHistory(state) {
    late List<dynamic> tempHistoryList;
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);

    tempHistoryList = bitcoinCubit.state.history ?? [];

    if (SettingsHelper.isBitcoin()) {
      return tempHistoryList.length > 30;
    } else if (SettingsHelper.settings.network == 'mainnet') {
      return state.activeAccount.historyList!.length > 30;
    } else {
      return state.activeAccount.testnetHistoryList!.length > 30;
    }
  }

  updateAccountDetails(context, state) async {
    lockHelper.provideWithLockChecker(context, () async {
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      if (state.status == AccountStatusList.success) {
        await accountCubit.updateAccountDetails();

        Future.delayed(const Duration(milliseconds: 1), () async {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => HomeScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        });
      }
    });
  }
}
