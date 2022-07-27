import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth_screen/auth_screen.dart';
import 'package:defi_wallet/widgets/buttons/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/screens/home/widgets/full_size_icon.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double leadingWidth = 100;
  static const double iconHeight = 20;
  static List<String> mnemonic = [];
  final List<TextEditingController>? controllers;
  final bool isSavedMnemonic;
  final bool isShowFullScreen;
  final bool? isSmall;
  final Widget? widgetBack;

  const AuthAppBar({
    Key? key,
    this.isSavedMnemonic = false,
    this.isShowFullScreen = false,
    this.isSmall = true,
    this.widgetBack,
    this.controllers,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: isSmall!
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            isSavedMnemonic
                ? backButton(context, callback: () async {
                    var box = await Hive.openBox(HiveBoxes.client);
                    await box.put(HiveNames.openedMnemonic, null);
                    await box.close();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => AuthScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  })
                : backButton(context)
          ],
        ),
      ),
      centerTitle: true,
      title: SvgPicture.asset(
        'assets/jelly_logo_wallet.svg',
        height: iconHeight,
      ),
      actions: [
        isShowFullScreen
            ? isSmall!
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
                          if (controllers != null) {
                            for (TextEditingController el in controllers!) {
                              mnemonic.add(el.text);
                            }
                            var box = await Hive.openBox(HiveBoxes.client);
                            await box.put(
                                HiveNames.recoveryMnemonic, mnemonic.join(','));
                            await box.close();
                          }
                          js.context
                              .callMethod('open', [window.location.toString()]);
                        },
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                  )
            : Container(
                padding: const EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
              ),
      ],
    );
  }
}
