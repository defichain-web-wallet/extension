import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/screens/earn_screen/earn_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screen.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/select_buy_or_sell_screen.dart';
import 'package:defi_wallet/screens/send/send_new.dart';
import 'package:defi_wallet/screens/send/send_token_selector.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionButtonsList extends StatelessWidget {
  final Function() hideOverlay;

  const ActionButtonsList({Key? key, required this.hideOverlay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var receiveCallback = () async {
      hideOverlay();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ReceiveScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    };

    var sendCallback = () {
      hideOverlay();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SendNew(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    };

    var swapCallback = () {
      if (SettingsHelper.isBitcoin() && SettingsHelper.settings.network == 'testnet') {
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
      hideOverlay();
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => SwapScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    };
    var liquidityCallback = () {
      hideOverlay();
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => EarnScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    };
    var buySellCallback = (state) {
      hideOverlay();
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                SelectBuyOrSellScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    };
    return BlocBuilder<FiatCubit, FiatState>(
      builder: (BuildContext context, state) {
        return Container(
          width: 340,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                iconPath: 'assets/images/receive.png',
                label: 'Receive',
                onPressed: receiveCallback,
              ),
              ActionButton(
                iconPath: 'assets/images/send.png',
                label: 'Send',
                onPressed: sendCallback,
              ),
              ActionButton(
                iconPath: 'assets/images/swap.png',
                label: 'Swap',
                onPressed: swapCallback,
              ),
              if (!SettingsHelper.isBitcoin())
                ActionButton(
                  iconPath: 'assets/images/buy_sell.png',
                  label: 'Buy/Sell',
                  onPressed: () => buySellCallback(state),
                ),
              if (!SettingsHelper.isBitcoin())
                ActionButton(
                  iconPath: 'assets/images/earn.png',
                  label: 'Earn',
                  onPressed: liquidityCallback,
                ),
            ],
          ),
        );
      },
    );
  }
}

class ActionButton extends StatelessWidget {
  final String? label;
  final String? iconPath;
  final Function()? onPressed;

  const ActionButton({Key? key, this.label, this.iconPath, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return Column(
      children: [
        Container(
          width: 35,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.pinkColor, width: 1.5),
          ),
          child: IconButton(
            splashRadius: 1,
            iconSize: 22,
            icon: Image(
              image: AssetImage(iconPath!),
              width: 12,
              height: 12,
            ),
            onPressed: () =>
                lockHelper.provideWithLockChecker(context, () => onPressed!()),
          ),
        ),
        Text(
          label!,
          style: Theme.of(context)
              .textTheme
              .headline4!
              .apply(color: AppTheme.pinkColor, fontSizeFactor: 0.9),
        ),
      ],
    );
  }
}
