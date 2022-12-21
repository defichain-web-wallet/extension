import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/dex/swap_guide_screen.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/screens/earn_screen/earn_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screeen_new.dart';
import 'package:defi_wallet/screens/receive/receive_screen.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/select_buy_or_sell_screen.dart';
import 'package:defi_wallet/screens/send/send_screen.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/home/account_balance.dart';
import 'package:defi_wallet/widgets/selectors/app_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({Key? key}) : super(key: key);

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  List<String> items = <String>['USD', 'EUR', 'BTC'];
  String activeAsset = 'USD';
  String swapTutorialStatus = 'show';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Column(
          children: [
            AppSelector(
              items: items,
              onSelect: (String name) {
                print(name);
                setState(() {
                  activeAsset = name;
                });
              },
            ),
            SizedBox(
              height: 12,
            ),
            AccountBalance(
              asset: activeAsset,
            ),
            SizedBox(
              height: 28,
            ),
            Row(
              children: [
                Flexible(
                  child: FlatButton(
                    title: 'Earn',
                    icon: SvgPicture.asset('assets/icons/earn_icon.svg'),
                    callback: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              EarnScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Flexible(
                  child: FlatButton(
                    title: 'Buy/Sell',
                    icon: SvgPicture.asset('assets/icons/wallet_icon.svg'),
                    callback: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              SelectBuyOrSellScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: [
                Flexible(
                  child: FlatButton(
                    title: 'Send',
                    isPrimary: false,
                    icon: SvgPicture.asset('assets/icons/send_icon.svg'),
                    callback: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => SendScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Flexible(
                  child: FlatButton(
                    title: 'Receive',
                    isPrimary: false,
                    icon: SvgPicture.asset('assets/icons/receive_icon.svg'),
                    callback: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => ReceiveScreenNew(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Flexible(
                  child: FlatButton(
                    title: 'Change',
                    isPrimary: false,
                    icon: SvgPicture.asset('assets/icons/change_icon.svg'),
                    callback: () {
                      if (SettingsHelper.isBitcoin() &&
                          SettingsHelper.settings.network == 'testnet') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Not allowed for testnet bitcoin',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
                          ),
                        );
                        return;
                      }
                      if (swapTutorialStatus == 'show' && SettingsHelper.isBitcoin()) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                SwapGuideScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => SwapScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
