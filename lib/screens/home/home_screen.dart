import 'dart:developer';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_state.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/requests/currency_requests.dart';
import 'package:defi_wallet/screens/home/widgets/action_buttons_list.dart';
import 'package:defi_wallet/screens/home/widgets/home_app_bar.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_body.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/screens/home/widgets/wallet_details.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final bool isLoadTokens;

  const HomeScreen({Key? key, this.isLoadTokens = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isSaveOpenTime = false;
  GlobalKey<AccountSelectState> _selectKey = GlobalKey<AccountSelectState>();
  CurrencyRequests currencyRequests = CurrencyRequests();
  LockHelper lockHelper = LockHelper();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  void hideOverlay() {
    try {
      _selectKey.currentState!.hideOverlay();
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
    if (!_isSaveOpenTime) {
      saveOpenTime();
      _isSaveOpenTime = true;
    }
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);
    if (widget.isLoadTokens) {
      tokensCubit.loadTokens();
    }
    transactionCubit.checkOngoingTransaction();

    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          return BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) {
            return ScaffoldConstrainedBox(
              child: GestureDetector(
                child: LayoutBuilder(builder: (context, constraints) {
                  if (state is AccountLoadingState ||
                      tokensState is TokensLoadingState) {
                    return Container(
                      child: Center(
                        child: Loader(),
                      ),
                    );
                  }

                  if (constraints.maxWidth < ScreenSizes.medium) {
                    return Scaffold(
                      appBar: HomeAppBar(
                        selectKey: _selectKey,
                        updateCallback: () =>
                            updateAccountDetails(context, state),
                        hideOverlay: () => hideOverlay(),
                        isShowBottom:
                            !(transactionState is TransactionInitialState),
                        height: !(transactionState is TransactionInitialState)
                            ? toolbarHeightWithBottom
                            : toolbarHeight,
                      ),
                      body: _buildBody(context, state, transactionState),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Scaffold(
                        body: _buildBody(context, state, transactionState),
                        appBar: HomeAppBar(
                          selectKey: _selectKey,
                          updateCallback: () =>
                              updateAccountDetails(context, state),
                          hideOverlay: () => hideOverlay(),
                          isShowBottom:
                              !(transactionState is TransactionInitialState),
                          height: !(transactionState is TransactionInitialState)
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

  Widget _buildBody(context, state, transactionState) {
    if (state is AccountLoadedState) {
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
                              padding:
                                  const EdgeInsets.only(bottom: 26, top: 20),
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
                              tabController: _tabController,
                            )),
                      ),
                      Flexible(
                          child: TabBarBody(
                        tabController: _tabController,
                        historyList: state.activeAccount.historyList!,
                      )),
                    ],
                  )),
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
                        )),
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
                            tabController: _tabController,
                          )),
                    ),
                  ),
                  Flexible(
                      child: TabBarBody(
                    tabController: _tabController,
                    historyList: state.activeAccount.historyList!,
                  )),
                ],
              ),
            )),
          );
        }
      });
    } else {
      return Container();
    }
  }

  updateAccountDetails(context, state) async {
    lockHelper.provideWithLockChecker(context, () async {
      hideOverlay();
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      if (state is AccountLoadedState) {
        await currencyRequests
            .getCoingeckoList(SettingsHelper.settings.currency!);
        await accountCubit.updateAccountDetails(state.mnemonic, state.seed,
            state.accounts, state.masterKeyPair, state.activeAccount);

        Future.delayed(const Duration(milliseconds: 1), () async {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
        });
      }
    });
  }
}
