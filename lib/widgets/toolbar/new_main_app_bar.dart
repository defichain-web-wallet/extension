import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/logo_helper.dart';
import 'package:defi_wallet/widgets/buttons/back_icon_button.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/selectors/network_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

class NewMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isShowLogo;
  final bool isShowNetworkSelector;
  final Color? bgColor;
  final void Function()? callback;

  const NewMainAppBar({
    Key? key,
    this.isShowLogo = true,
    this.isShowNetworkSelector = true,
    this.bgColor,
    this.callback,
  }) : super(key: key);

  static const double toolbarHeight = 54.0;
  static const double iconSize = 20.0;
  static const double logoWidth = 26.0;
  static const double logoLeftPadding = 16.0;
  static const double leadingWidth = logoWidth + logoLeftPadding;

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
        backgroundColor: bgColor != null
            ? bgColor
            : Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: toolbarHeight,
        elevation: 0,
        leadingWidth: leadingWidth,
        leading: isShowLogo
            ? Container(
                margin: const EdgeInsets.only(left: logoLeftPadding),
                child: LogoHelper().getLogo(),
              )
            : BackIconButton(
                leftPadding: logoLeftPadding - 2,
                width: iconSize,
                height: iconSize,
              ),
        title: isShowNetworkSelector
            ? NetworkSelector(
                onSelect: () {},
              )
            : Container(),
        actions: [
          if (isShowLogo)
            SizedBox(
              width: 32,
              height: 32,
              child: NewActionButton(
                iconPath: 'assets/icons/fullscreen_icon.svg',
                onPressed: () => lockHelper.provideWithLockChecker(
                    context,
                    () => js.context
                        .callMethod('open', [window.location.toString()])),
              ),
            ),
          SizedBox(
            width: 16,
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: NewActionButton(
              iconPath: 'assets/icons/account_icon.svg',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          SizedBox(
            width: 16,
          )
        ],
      ),
    );
  }
}
