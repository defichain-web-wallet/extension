import 'dart:developer';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/widgets/action_buttons_list.dart';
import 'package:defi_wallet/screens/home/widgets/home_app_bar.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_body.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/screens/home/widgets/wallet_details.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    transactionCubit.checkOngoingTransaction();

    if (widget.isLoadTokens && SettingsHelper.settings.network == 'mainnet') {
      fiatCubit.loadUserDetails(accountCubit.state.accessToken!);
    }
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

  Future<void> saveOpenTime() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.openTime, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    if (!isSaveOpenTime) {
      saveOpenTime();
      isSaveOpenTime = true;
    }
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    if (widget.isLoadTokens) {
      tokensCubit.loadTokensFromStorage();
    }

    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          return BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) {
                return ScaffoldConstrainedBox(
                  child: GestureDetector(
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (state.status == AccountStatusList.loading ||
                          tokensState.status == TokensStatusList.loading) {
                        return Container(
                          child: Center(
                            child: Loader(),
                          ),
                        );
                      }

                      if (constraints.maxWidth < ScreenSizes.medium) {
                        return Scaffold(
                          appBar: HomeAppBar(
                            selectKey: selectKey,
                            updateCallback: () =>
                                updateAccountDetails(context, state),
                            hideOverlay: () => hideOverlay(),
                            isShowBottom:
                            !(transactionState is TransactionInitialState),
                            height: !(transactionState is TransactionInitialState)
                                ? toolbarHeightWithBottom
                                : toolbarHeight,
                          ),
                          body: _buildBody(
                              context, state, transactionState, tokensState),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Scaffold(
                            body: _buildBody(
                                context, state, transactionState, tokensState),
                            appBar: HomeAppBar(
                              selectKey: selectKey,
                              updateCallback: () =>
                                  updateAccountDetails(context, state),
                              hideOverlay: () => hideOverlay(),
                              isShowBottom:
                              !(transactionState is TransactionInitialState),
                              height:
                              !(transactionState is TransactionInitialState)
                                  ? toolbarHeightWithBottom
                                  : toolbarHeight,
                              isSmall: false,
                            ),
                          ),
                        );
                      }
                    }),
                    onTap: () => hideOverlay(),
                  ),
                );
          });
        },
      );
    });
  }

  Widget _buildBody(context, state, transactionState, tokensState) {
    if (state.status == AccountStatusList.success &&
        tokensState.status == TokensStatusList.success) {
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < ScreenSizes.medium) {
          return Container(
            child: Center(
              child: StretchBox(
                maxWidth: ScreenSizes.medium,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Theme.of(context).dialogBackgroundColor,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 26, top: 20),
                            child: WalletDetails(layoutSize: 'small'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ActionButtonsList(
                              hideOverlay: () => hideOverlay(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowColor.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: TabBarHeader(
                          tabController: tabController,
                        ),
                      ),
                    ),
                    Flexible(
                      child: TabBarBody(
                        tabController: tabController,
                        historyList: state.activeAccount.historyList!,
                        testnetHistoryList: state.activeAccount.testnetHistoryList!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(
            child: Center(
              child: StretchBox(
                maxWidth: ScreenSizes.medium,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Theme.of(context).dialogBackgroundColor,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: WalletDetails(layoutSize: 'large'),
                          ),
                          Expanded(
                            child: ActionButtonsList(
                              hideOverlay: () => hideOverlay(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowColor.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: TabBarHeader(
                            tabController: tabController,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: TabBarBody(
                        tabController: tabController,
                        historyList: state.activeAccount.historyList!,
                        testnetHistoryList: state.activeAccount.testnetHistoryList!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      });
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
