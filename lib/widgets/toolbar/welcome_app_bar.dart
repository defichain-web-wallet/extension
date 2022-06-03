import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double iconHeight = 30;

  const WelcomeAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: toolbarHeight,
      elevation: 0,
      title: Center(
        child: SvgPicture.asset(
          'assets/jelly_logo_wallet.svg',
          height: iconHeight,
        ),
      ),
    );
  }
}
