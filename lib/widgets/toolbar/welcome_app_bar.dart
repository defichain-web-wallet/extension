import 'package:defi_wallet/widgets/toolbar/auth_progress_bar.dart';
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
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      toolbarHeight: toolbarHeight,
      bottom: AuthProgressBar(
        fill: 0.3,
      ),
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/arrow_back.svg',
          width: 20,
          height: 20,
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