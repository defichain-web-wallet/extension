import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/dex/swap_guide_screen.dart';
import 'package:defi_wallet/screens/earn/earn_screen.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/buy_sell_screen.dart';
import 'package:defi_wallet/screens/swap/swap_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screeen_new.dart';
import 'package:defi_wallet/screens/send/send_screeen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/home/account_balance.dart';
import 'package:defi_wallet/widgets/selectors/app_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCard extends StatefulWidget {
  final bool isFullScreen;

  HomeCard({Key? key, this.isFullScreen = false}) : super(key: key);

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> with ThemeMixin {
  static const double homeCardWidth = 328;
  static const double homeCardHeight = 266;
  List<String> items = <String>['USD', 'EUR', 'BTC'];
  String activeAsset = 'USD';
  String swapTutorialStatus = 'show';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);

    return Container(
      width: homeCardWidth,
      height: homeCardHeight,
      padding: const EdgeInsets.only(left: 12, top: 22, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: isDarkTheme() ? Border.all(
            width: 1,
            color: Colors.white.withOpacity(0.04)) : null,
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 21,
              child: AppSelector(
                items: items,
                onSelect: (String name) {
                  print(name);
                  setState(() {
                    activeAsset = name;
                  });
                },
              ),
            ),
            SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 56,
              child: AccountBalance(
                asset: activeAsset,
              ),
            ),
            SizedBox(
              height: 31,
            ),
            Row(
              children: [
                Flexible(
                  child: FlatButton(
                    title: 'Earn',
                    iconPath: walletCubit.state.isSendReceiveOnly
                        ? 'assets/icons/earn_disabled.png'
                        : 'assets/icons/earn.png',
                    callback: walletCubit.state.isSendReceiveOnly ? null : () {
                      NavigatorService.push(context, EarnScreen());
                    },
                  ),
                ),
                SizedBox(
                  width: 8.0,
                ),
                Flexible(
                  child: FlatButton(
                    title: 'Buy/Sell',
                    iconPath: walletCubit.state.isSendReceiveOnly
                        ? 'assets/icons/wallet_disabled.png'
                        : 'assets/icons/wallet.png',
                    callback: walletCubit.state.isSendReceiveOnly ? null : () {
                      NavigatorService.push(context, BuySellScreen());
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 7.0,
            ),
            Row(
              children: [
                Flexible(
                  child: FlatButton(
                    title: 'Send',
                    isPrimary: false,
                    iconPath: 'assets/icons/send_icon.svg',
                    callback: () {
                      NavigatorService.push(context, SendScreen());
                    },
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Flexible(
                  child: FlatButton(
                    title: 'Receive',
                    isPrimary: false,
                    iconPath: 'assets/icons/receive_icon.svg',
                    callback: () {
                      NavigatorService.push(context, ReceiveScreenNew());
                    },
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Flexible(
                  child: BlocBuilder<AccountCubit, AccountState>(
                    builder: (context, accountState) {
                      return FlatButton(
                        title: 'Change',
                        isPrimary: false,
                      iconPath: walletCubit.state.isSendReceiveOnly
                          ? 'assets/icons/change_icon_disabled.svg'
                          : 'assets/icons/change_icon.svg',
                      callback: walletCubit.state.isSendReceiveOnly ? null : () {
                          late Widget changeWidget;
                          if (walletCubit.state.isSendReceiveOnly) {
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
                          if (accountState.swapTutorialStatus == 'show' && walletCubit.state.isSendReceiveOnly) {
                            changeWidget = SwapGuideScreen();
                          } else {
                            changeWidget = SwapScreen();
                          }
                          NavigatorService.push(context, changeWidget);
                        },
                      );
                    }
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
