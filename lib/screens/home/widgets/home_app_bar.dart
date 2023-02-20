// import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
// import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/logo_helper.dart';
import 'package:defi_wallet/screens/home/widgets/account_select.dart';
import 'package:defi_wallet/screens/home/widgets/full_size_icon.dart';
import 'package:defi_wallet/screens/home/widgets/settings_list.dart';
import 'package:defi_wallet/widgets/buttons/cancel_button.dart';
import 'package:defi_wallet/widgets/ongoing_transaction.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double leadingWidth = 120;
  static const double toolbarHeight = 55;
  static const double accountSelectSmallHeight = 170;
  static const double accountSelectMediumHeight = 270;

  final GlobalKey<AccountSelectState>? selectKey;
  final Function()? updateCallback;
  final Function()? hideOverlay;
  final double height;
  final bool isShowBottom;
  final bool isSmall;
  final bool isSettingsList;
  final bool isRefresh;

  const HomeAppBar(
      {Key? key,
      this.selectKey,
      this.updateCallback,
      this.hideOverlay,
      this.height = toolbarHeight,
      this.isShowBottom = false,
      this.isSmall = true,
      this.isSettingsList = true,
      this.isRefresh = true})
      : super(key: key);

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    LogoHelper logoHelper = LogoHelper();
    LockHelper lockHelper = LockHelper();

    return AppBar(
      shadowColor: Colors.transparent,
      bottom: isShowBottom ? OngoingTransaction() : null,
      shape: isSmall
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
      automaticallyImplyLeading: false,
      leadingWidth: leadingWidth,
      leading: isSmall
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: logoHelper.getLogo(),
            ),
      title: isSmall
          ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              AccountSelect(
                key: selectKey,
                width: accountSelectSmallHeight,
                isFullScreen: false,
              )
            ])
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AccountSelect(
                  key: selectKey,
                  width: accountSelectMediumHeight,
                  isFullScreen: true,
                )
              ],
            ),
      actions: [
        isSmall
            ? Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: FullSizeIcon(),
                    splashRadius: 18,
                    onPressed: () async {
                      // TODO: uncomment later
                      // lockHelper.provideWithLockChecker(
                      //     context,
                      //     () => js.context.callMethod(
                      //         'open', [window.location.toString()]));
                    },
                  ),
                ),
              )
            : Container(
                width: isRefresh ? 0 : 65,
                padding: const EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
              ),
        isRefresh
            ? SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                    padding: const EdgeInsets.all(0),
                    splashRadius: 18,
                    icon: Icon(Icons.refresh),
                    color:
                        Theme.of(context).appBarTheme.actionsIconTheme!.color,
                    onPressed: updateCallback))
            : Container(),
        Padding(
          padding: EdgeInsets.only(right: 6),
          child: isSettingsList
              ? SettingsList(onSelect: () => hideOverlay!())
              : CancelButton(),
        )
      ],
    );
  }
}
