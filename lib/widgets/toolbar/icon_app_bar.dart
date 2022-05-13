import 'package:defi_wallet/widgets/buttons/cancel_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double leadingWidth = 100;
  static const double iconHeight = 20;

  final String? title;
  final Function()? cancel;
  final bool? isSmall;
  final bool? isShownLogo;

  const IconAppBar(
      {Key? key,
      this.title,
      this.cancel,
      this.isSmall = false,
      this.isShownLogo = true})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: !isSmall!
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
      leadingWidth: isShownLogo! ? 100 : 0,
      toolbarHeight: 50,
      leading: isShownLogo!
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SvgPicture.asset('assets/jelly_logo_new.svg'),
            )
          : Container(),
      centerTitle: true,
      title: Text(
        title!,
        style: Theme.of(context).textTheme.headline6,
      ),
      actions: [
        CancelButton(callback: cancel),
      ],
    );
  }
}
