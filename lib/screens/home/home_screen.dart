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
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/home/home_extended_view.dart';
import 'package:defi_wallet/widgets/home/home_tabs_scroll_view.dart';
import 'package:defi_wallet/widgets/home/transaction_status_bar.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
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
  static const int tickerTimerUpdate = 15;
  static const double extendedBoxWidth = 832;
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
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    if (widget.isLoadTokens) {
      tokensCubit.loadTokensFromStorage();
    }

    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (SettingsHelper.isBitcoin()) {
        bitcoinCubit.loadDetails(state.activeAccount!.bitcoinAddress!);
      }
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
                  key: _scaffoldKey,
                  appBar: NewMainAppBar(
                    isShowLogo: true,
                    isSmallScreen: !isFullScreen,
                  ),
                  drawerScrimColor: isFullScreen
                      ? Colors.transparent
                      : AppColors.tolopea.withOpacity(0.06),
                  endDrawer: AccountDrawer(
                    width: isFullScreen ? 298 : buttonSmallWidth,
                    isFullScreen: isFullScreen,
                  ),
                  body: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, homeState) {
                      if (timer == null && !SettingsHelper.isBitcoin()) {
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
                            maxWidth: extendedBoxWidth,
                            child: Container(
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
                                  if (txState is! TransactionInitialState)
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
              }
            },
          );
        },
      );
    });
  }
}
