import 'package:defi_wallet/screens/liquidity/earn_screen_new.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/buy_sell_screen.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/home/account_balance.dart';
import 'package:flutter/material.dart';

class HomeTitle extends StatelessWidget {
  final double sliverTopHeight;
  final double targetSliverTopHeight;
  final String activeAsset;

  const HomeTitle({
    Key? key,
    required this.sliverTopHeight,
    required this.targetSliverTopHeight,
    required this.activeAsset,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    if (sliverTopHeight != targetSliverTopHeight) {
      return Container();
    }
    return AnimatedOpacity(
      opacity: sliverTopHeight ==
          targetSliverTopHeight
          ? 1.0
          : 0.0,
      duration:
      const Duration(
          milliseconds:
          200),
      child: Container(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child:
              AccountBalance(
                asset: activeAsset,
                isSmall: true,
              ),
            ),
            SizedBox(
              width: 72,
              child:
              FlatButton(
                title: '',
                iconPath:
                'assets/icons/earn_icon.svg',
                isSmall: true,
                callback: () {
                  Navigator
                      .push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context,
                          animation1,
                          animation2) =>
                          EarnScreenNew(),
                      transitionDuration:
                      Duration.zero,
                      reverseTransitionDuration:
                      Duration.zero,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: 8,
            ),
            SizedBox(
              width: 72,
              child:
              FlatButton(
                title: '',
                iconPath:
                'assets/icons/wallet_icon.svg',
                isSmall: true,
                callback: () {
                  Navigator
                      .push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context,
                          animation1,
                          animation2) =>
                          BuySellScreen(),
                      transitionDuration:
                      Duration.zero,
                      reverseTransitionDuration:
                      Duration.zero,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
