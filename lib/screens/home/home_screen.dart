import 'dart:developer';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/widgets/action_buttons_list.dart';
import 'package:defi_wallet/screens/home/widgets/home_app_bar.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_body.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/screens/home/widgets/wallet_details.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/home/home_card.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/network/network_selector.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final bool isLoadTokens;

  const HomeScreen({Key? key, this.isLoadTokens = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
      countAssets = 1;
    } else {
      countAssets = accountState.activeAccount!.balanceList!
          .where((el) => !el.isHidden!)
          .length
          .toDouble();
    }
    assetsTabBodyHeight =
        countAssets * heightListEntry + heightAdditionalAction;

    countTransactions = (SettingsHelper.isBitcoin())
        ? bitcoinCubit.state.history!.length.toDouble()
        : accountState.activeAccount!.historyList!.length.toDouble();
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
              }

              return Scaffold(
                appBar: NewMainAppBar(
                  isShowLogo: true,
                ),
                body: _buildBody(
                  context,
                  state,
                  txState,
                  tokensState,
                  isFullSize: isFullScreen,
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildBody(context, state, transactionState, tokensState,
      {isFullSize = false}) {
    if (state.status == AccountStatusList.success &&
        tokensState.status == TokensStatusList.success) {
      isFullSizeScreen = isFullSize;
      setTabBody(tabIndex: tabController!.index);
      return BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: StretchBox(
                maxWidth: ScreenSizes.medium,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    HomeCard(),
                    SizedBox(
                      height: 34,
                    ),
                    Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                          ),
                          child: TabBarHeader(
                            tabController: tabController,
                          ),
                        ),
                      ),
                    ),
                    homeState.tabIndex == 0
                        ? SizedBox(
                            height: assetsTabBodyHeight,
                            child: TabBarBody(
                              tabController: tabController,
                              isEmptyList: isExistHistory(state),
                            ),
                          )
                        : SizedBox(
                            height: historyTabBodyHeight,
                            child: TabBarBody(
                              tabController: tabController,
                              isEmptyList: isExistHistory(state),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      );
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
  }

  bool isExistHistory(state) {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);

    if (SettingsHelper.isBitcoin()) {
      return bitcoinCubit.state.history!.length > 30;
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
