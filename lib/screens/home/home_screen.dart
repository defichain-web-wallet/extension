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
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_body.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/tokens/add_token_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/home/home_card.dart';
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

class _HomeScreenState extends State<HomeScreen> with SnackBarMixin, TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController;
  bool isSaveOpenTime = false;
  GlobalKey<AccountSelectState> selectKey = GlobalKey<AccountSelectState>();
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

  tabListener() {
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);
    homeCubit.updateTabIndex(index: tabController!.index);
    setTabBody(tabIndex: tabController!.index);
  }

  setTabBody({int tabIndex = 0}) {
    AccountState accountState = BlocProvider.of<AccountCubit>(context).state;
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    double countAssets = 0;
    double countTransactions = 0;

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
    tabController = TabController(length: 2, vsync: this);
    tabController!.addListener(tabListener);
    TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);

    transactionCubit.checkOngoingTransaction();

    lockHelper.updateTimer();
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  void hideOverlay() {
    try {
      selectKey.currentState!.hideOverlay();
    } catch (err) {
      log('error when try to hide overlay: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    if (widget.isLoadTokens) {
      tokensCubit.loadTokensFromStorage();
    }

    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          return ScaffoldWrapper(
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
              } else if (state.status == AccountStatusList.success &&
                  tokensState.status == TokensStatusList.success) {
                isFullSizeScreen = isFullScreen;
                setTabBody(tabIndex: tabController!.index);

              } else if (tokensState.status == TokensStatusList.failure) {
                return Container(
                  child: Center(
                    child: ErrorPlaceholder(
                      message: 'API error',
                      description: 'Please change the API on settings and try again',
                    ),
                  ),
                );
              } else {
                return Container();
              }

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
                    if (widget.snackBarMessage.isNotEmpty && !isShownSnackBar) {
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
                                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                child: ListView(
                                  children: [
                                    SizedBox(
                                      height: 5,
                                    ),
                                    HomeCard(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 12, right: 24),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TabBarHeader(
                                            tabController: tabController,
                                          ),
                                          Container(
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: SvgPicture.asset(
                                                    'assets/icons/filter_icon.svg',
                                                    color:
                                                    SettingsHelper.settings.theme == 'Dark'
                                                        ? Colors.white
                                                        : null,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: NewActionButton(
                                                    iconPath: 'assets/icons/add_black.svg',
                                                    onPressed: () async {
                                                      await lockHelper.provideWithLockChecker(
                                                        context,
                                                            () => Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (context, animation1,
                                                                animation2) =>
                                                                AddTokenScreen(),
                                                            transitionDuration: Duration.zero,
                                                            reverseTransitionDuration:
                                                            Duration.zero,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    if (homeState.tabIndex == 0)
                                      SizedBox(
                                        height: assetsTabBodyHeight,
                                        child: TabBarBody(
                                          tabController: tabController,
                                          isEmptyList: isExistHistory(state),
                                        ),
                                      )
                                    else
                                      SizedBox(
                                        height: historyTabBodyHeight,
                                        child: TabBarBody(
                                          tabController: tabController,
                                          isEmptyList: isExistHistory(state),
                                        ),
                                      ),
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
      hideOverlay();
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
