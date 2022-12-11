import 'package:defi_wallet/widgets/toolbar/auth_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress;
  final Function()? onBack;

  const WelcomeAppBar({
    Key? key,
    this.progress = 0,
    this.onBack,
  }) : super(key: key);

  static const String title = 'JellyWallet';
  static const double toolbarHeight = 54;
  static const double iconSize = 20;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  // TODO: review it for try to remove unnecessary call [onBack]
  _onPressedBack(BuildContext context) {
    if (onBack == null) {
      Navigator.pop(context);
    } else {
      onBack!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(toolbarHeight),
      child: AppBar(
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: toolbarHeight,
        bottom: progress != 0
            ? AuthProgressBar(
                fill: progress,
              )
            : null,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            width: iconSize,
            height: iconSize,
          ),
          onPressed: () => _onPressedBack(context),
          splashRadius: 20,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
