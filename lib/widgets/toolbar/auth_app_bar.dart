import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth_screen/auth_screen.dart';
import 'package:defi_wallet/widgets/buttons/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double leadingWidth = 100;
  static const double iconHeight = 30;
  final bool isSavedMnemonic;

  const AuthAppBar({Key? key, this.isSavedMnemonic = false}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(),
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
    );
  }
}
