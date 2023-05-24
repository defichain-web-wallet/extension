import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/widgets/home/home_card.dart';
import 'package:defi_wallet/widgets/home/home_tabs_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeExtendedView extends StatelessWidget {
  final double firstColumnWidth;
  final double lastColumnWidth;
  final TransactionState txState;
  final TabController tabController;

  HomeExtendedView({
    Key? key,
    required this.firstColumnWidth,
    required this.lastColumnWidth,
    required this.txState,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, current) => true,
      builder: (context, homeState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: firstColumnWidth,
              child: Column(
                children: [
                  HomeCard(
                    isFullScreen: true,
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: lastColumnWidth,
                ),
                child: (homeState.scrollView == null || homeState.isShownHome)
                    ? HomeTabsScrollView(
                        txState: txState,
                        tabController: tabController,
                        activeTabIndex: homeState.tabIndex,
                      )
                    : homeState.scrollView,
              ),
            ),
          ],
        );
      },
    );
  }
}
