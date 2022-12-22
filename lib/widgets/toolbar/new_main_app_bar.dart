import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/logo_helper.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter

class NewMainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isShowLogo;

  const NewMainAppBar({
    Key? key,
    this.isShowLogo = true,
  }) : super(key: key);

  static const double toolbarHeight = 54.0;
  static const double iconSize = 20.0;
  static const double logoWidth = 42.0;
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        toolbarHeight: toolbarHeight,
        elevation: 0,
        leadingWidth: leadingWidth,
        leading: isShowLogo
            ? Container(
                margin: const EdgeInsets.only(left: logoLeftPadding),
                child: LogoHelper().getLogo(),
              )
            : IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/arrow_back.svg',
                  width: iconSize,
                  height: iconSize,
                ),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
        title: Container(
          height: 24,
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFF00CF21),
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Text('DefiChain Mainnet', style: Theme.of(context).textTheme.subtitle2!.copyWith(
                fontWeight: FontWeight.w500,
              ),),
              SizedBox(
                width: 6,
              ),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFFB7B2C1), size: 14,)
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: 32,
            height: 32,
            child: NewActionButton(
              iconPath: 'assets/icons/fullscreen_icon.svg',
              onPressed: () => lockHelper.provideWithLockChecker(
                context,
                () => js.context.callMethod('open', [
                  window.location.toString(),
                ]),
              ),
            ),
          ),
          SizedBox(
            width: 12,
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
