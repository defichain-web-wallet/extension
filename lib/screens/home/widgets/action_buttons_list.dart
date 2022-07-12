import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/buy/contact_screen.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screen.dart';
import 'package:defi_wallet/screens/sell/account_type_sell.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/screens/send/send_token_selector.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
          pageBuilder: (context, animation1, animation2) => SendTokenSelector(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    };

    var swapCallback = () {
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
            pageBuilder: (context, animation1, animation2) => LiquidityScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    };
    var buyCallback = (state) {
      if (SettingsHelper.settings.network == 'testnet') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Forbidden to testnet',
              style: Theme.of(context).textTheme.headline5,
            ),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
        return;
      }
      if (state.isShowTutorial) {
        hideOverlay();
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ContactScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      } else {
        hideOverlay();
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SearchBuyToken(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      }
    };
    var sellCallback = (state) async {
      if (SettingsHelper.settings.network == 'testnet') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Forbidden to testnet',
              style: Theme.of(context).textTheme.headline5,
            ),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
        return;
      }
      var box = await Hive.openBox(HiveBoxes.client);
      var kycStatus = await box.get(HiveNames.kycStatus);
      bool isSkipKyc = kycStatus == 'skip';
      await box.close();
      hideOverlay();
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                isSkipKyc ? Selling() : AccountTypeSell(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    };
    return BlocBuilder<FiatCubit, FiatState>(
      builder: (BuildContext context, state) {
        return Row(
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
            ActionButton(
              iconPath: 'assets/images/liquidity.png',
              label: 'Liquidity',
              onPressed: liquidityCallback,
            ),
            ActionButton(
              iconPath: 'assets/images/buy.png',
              label: 'Buy',
              onPressed: () => buyCallback(state),
            ),
            ActionButton(
              iconPath: 'assets/images/sell.png',
              label: 'Sell',
              onPressed: () => sellCallback(state),
            ),
          ],
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
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.pinkColor, width: 2),
          ),
          child: IconButton(
            iconSize: 26,
            icon: Image(
              image: AssetImage(iconPath!),
              width: 15,
              height: 15,
            ),
            onPressed: () =>
                lockHelper.provideWithLockChecker(context, () => onPressed!()),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label!,
          style: Theme.of(context)
              .textTheme
              .headline3!
              .apply(color: AppTheme.pinkColor),
        ),
      ],
    );
  }
}
