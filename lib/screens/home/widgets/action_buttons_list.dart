import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screen.dart';
import 'package:defi_wallet/screens/send/send_token_selector.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

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
        MaterialPageRoute(
          builder: (context) => ReceiveScreen(),
        ),
      );
    };

    var sendCallback = () {
      hideOverlay();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendTokenSelector(),
        ),
      );
    };

    var swapCallback = () {
      hideOverlay();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SwapScreen(),
          ));
    };
    var liquidityCallback = () {
      hideOverlay();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiquidityScreen(),
          ));
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
            iconPath: 'assets/images/receive.png',
            label: 'Receive',
            onPressed: receiveCallback),
        ActionButton(
            iconPath: 'assets/images/send.png',
            label: 'Send',
            onPressed: sendCallback),
        ActionButton(
            iconPath: 'assets/images/swap.png',
            label: 'Swap',
            onPressed: swapCallback),
        ActionButton(
            iconPath: 'assets/images/liquidity.png',
            label: 'Liquidity',
            onPressed: liquidityCallback),
      ],
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
