import 'package:defi_wallet/screens/liquidity/earn_screen_new.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/buy_sell_screen.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/common/app_tooltip.dart';
import 'package:defi_wallet/widgets/home/account_balance.dart';
import 'package:defi_wallet/widgets/home/home_card.dart';
import 'package:flutter/material.dart';

class HomeSliverAppBar extends StatefulWidget {
  const HomeSliverAppBar({Key? key}) : super(key: key);

  @override
  State<HomeSliverAppBar> createState() => _HomeSliverAppBarState();
}

class _HomeSliverAppBarState extends State<HomeSliverAppBar> {
  double sliverTopHeight = 0.0;
  double targetSliverTopHeight = 76.0;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      actions: [Container()],
      automaticallyImplyLeading: false,
      toolbarHeight: 56 + 20,
      expandedHeight: 266 + 30,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          sliverTopHeight = constraints.biggest.height;
          return SafeArea(
            child: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              title: sliverTopHeight == targetSliverTopHeight
                  ? AnimatedOpacity(
                      opacity:
                          sliverTopHeight == targetSliverTopHeight ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 56,
                        child: Row(
                          children: [
                            Expanded(
                              child: AccountBalance(
                                asset: 'USD',
                                isSmall: true,
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: AppTooltip(
                                message: 'Earn',
                                child: FlatButton(
                                  title: '',
                                  iconPath: 'assets/icons/earn_icon.svg',
                                  isSmall: true,
                                  callback: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                EarnScreenNew(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 72,
                              child: AppTooltip(
                                message: 'Buy/Sell',
                                child: FlatButton(
                                  title: '',
                                  iconPath: 'assets/icons/wallet_icon.svg',
                                  isSmall: true,
                                  callback: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                BuySellScreen(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration: Duration.zero,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
              background: Container(
                height: 266,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: HomeCard(),
              ),
            ),
          );
        },
      ),
    );
  }
}
