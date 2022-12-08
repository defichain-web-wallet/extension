import 'package:defi_wallet/widgets/toolbar/auth_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress;

  const WelcomeAppBar({
    Key? key,
    this.progress = 0,
  }) : super(key: key);

  static const double toolbarHeight = 50;
  static const double iconSize = 20;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        onPressed: () {
          Navigator.pop(context);
        },
        splashRadius: 20,
      ),
      title: Text(
        'JellyWallet',
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
