import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/widgets/asset_list.dart';
import 'package:defi_wallet/screens/home/widgets/tab_bar/tab_bar_header.dart';
import 'package:defi_wallet/screens/home/widgets/transaction_history.dart';
import 'package:defi_wallet/screens/tokens/add_token_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/home/home_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTabsScrollView extends StatefulWidget {
  final TransactionState txState;
  final TabController tabController;
  final int activeTabIndex;
  final bool isShowHomeCard;

  const HomeTabsScrollView({
    Key? key,
    required this.txState,
    required this.tabController,
    required this.activeTabIndex,
    this.isShowHomeCard = false,
  }) : super(key: key);

  @override
  State<HomeTabsScrollView> createState() => _HomeTabsScrollViewState();
}

class _HomeTabsScrollViewState extends State<HomeTabsScrollView> {
  LockHelper lockHelper = LockHelper();

  @override
  Widget build(BuildContext context) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: CustomScrollView(
        slivers: [
          if (widget.isShowHomeCard)
            HomeSliverAppBar(),
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            actions: [Container()],
            automaticallyImplyLeading: false,
            expandedHeight: 58.0,
            toolbarHeight: 58,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 12,
                    right: 16,
                    bottom: 2,
                  ),
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
                      Expanded(
                        child: TabBarHeader(
                          tabController: widget.tabController,
                          currentTabIndex: widget.activeTabIndex,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      if (!SettingsHelper.isBitcoin())
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: NewActionButton(
                            iconPath: 'assets/icons/add_black.svg',
                            onPressed: () {
                              NavigatorService.push(
                                context,
                                AddTokenScreen(),
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
          if (widget.tabController.index == 0) ...[
            AssetList(),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                height: widget.txState is! TransactionInitialState ? 90 : 0,
                color: Theme.of(context).cardColor,
              ),
            )
          ] else ...[
            TransactionHistory(),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                height: widget.txState is! TransactionInitialState ? 90 : 0,
                color: Theme.of(context).cardColor,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
