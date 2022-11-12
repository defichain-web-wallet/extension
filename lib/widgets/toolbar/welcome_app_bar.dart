import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double iconHeight = 30;
  bool isBgWhite;

  WelcomeAppBar({
    Key? key,
    this.isBgWhite = false,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      backgroundColor:
          isBgWhite ? null : Theme.of(context).dialogBackgroundColor,
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
