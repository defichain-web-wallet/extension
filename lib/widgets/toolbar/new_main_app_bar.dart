import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/logo_helper.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/toolbar/auth_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

class NewMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onBack;

  const NewMainAppBar({
    Key? key,
    this.onBack,
  }) : super(key: key);

  static const double toolbarHeight = 54;
  static const double iconSize = 20;
  static const double accountSelectSmallHeight = 119;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return PreferredSize(
        preferredSize: Size.fromHeight(toolbarHeight),
        child: AppBar(
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            toolbarHeight: toolbarHeight,
            elevation: 0,
            leading: onBack == null
                ? LogoHelper().getLogo()
                : IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/arrow_back.svg',
                      width: iconSize,
                      height: iconSize,
                    ),
                    onPressed: () => onBack!(),
                    splashRadius: 20,
                  ),
            title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              AccountSelect(
                width: accountSelectSmallHeight,
                isFullScreen: false,
              )
            ]),
            actions: [
              NewActionButton(
                  iconPath: 'assets/icons/fullscreen_icon.svg',
                  onPressed: () => lockHelper.provideWithLockChecker(
                      context,
                      () => js.context
                          .callMethod('open', [window.location.toString()]))),
              NewActionButton(iconPath: 'assets/icons/account_icon.svg', onPressed: ()=>{},)
            ]));
  }
}
