import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/settings/accounts/rename_accounts.dart';
import 'package:defi_wallet/screens/settings/settings.dart';
import 'package:defi_wallet/screens/settings/favorite_tokens/my_favorite_tokens.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

class SettingsList extends StatefulWidget {
  final void Function() onSelect;

  SettingsList({Key? key, required this.onSelect}) : super(key: key);

  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  CustomPopupMenuController _controller = CustomPopupMenuController();
  LockHelper lockHelper = LockHelper();
  MenuHelper menuHelper = MenuHelper();
  final List<dynamic> menuItems = [
    {'name': 'arrow'},
    {'name': 'Rename accounts', 'value': (context, animation1, animation2) => RenameAccounts()},
    {'name': 'My tokens', 'value': (context, animation1, animation2) => MyFavoriteTokens()},
    {'name': 'Settings', 'value': (context, animation1, animation2) => Settings()},
    {'name': 'Lock wallet', 'value': (context, animation1, animation2) => null}
  ];

  void lockWallet() async {
    await lockHelper.lockWallet();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>  LockScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,),
    );
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);

    return CustomPopupMenu(
      menuOnChange: (b) {
        widget.onSelect();
        setState(() {});
      },
      child: IconButton(
        icon: Icon(Icons.more_vert),
        splashRadius: 18,
        color: _controller.menuIsShowing
            ? AppTheme.pinkColor
            : Theme.of(context).appBarTheme.actionsIconTheme!.color,
        onPressed: () {
          lockHelper.provideWithLockChecker(context, () async {
            _controller.showMenu();
            setState(() {});
          });
        },
      ),
      menuBuilder: () => CustomPaint(
        painter: ArrowPainter(),
        child: ClipPath(
          clipper: ArrowClipper(),
          child: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: menuItems
                  .map(
                    (item) => item['name'] == 'arrow'
                        ? Container(height: 10)
                        : Column(
                            children: [
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shadowColor: Colors.transparent,
                                      primary: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      side: BorderSide(
                                        color: Colors.transparent,
                                      )),
                                  onPressed: () {
                                    _controller.hideMenu();
                                    widget.onSelect();
                                    if (item['name'] == 'Lock wallet') {
                                      lockWallet();
                                    } else {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: item['value'],  transitionDuration: Duration.zero,
                                          reverseTransitionDuration: Duration.zero,),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: item['name'] == 'Lock wallet' ?
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  item['name'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline4,
                                                ),
                                                  Icon(Icons.lock_outline,
                                                      size: 14,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color),
                                                ],
                                            )
                                            : Text(
                                          item['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: item == menuItems.last ? 0 : 1,
                                color: AppTheme.lightGreyColor,
                              ),
                            ],
                          ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      showArrow: false,
      barrierColor: Colors.transparent,
      pressType: PressType.singleClick,
      verticalMargin: -5,
      horizontalMargin: horizontalMargin,
      controller: _controller,
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(10, 10)
      ..arcToPoint(Offset(0, 20), radius: Radius.circular(10), clockwise: false)
      ..lineTo(0, size.height - 10)
      ..arcToPoint(Offset(10, size.height),
          radius: Radius.circular(10), clockwise: false)
      ..lineTo(size.width - 10, size.height)
      ..arcToPoint(Offset(size.width, size.height - 10),
          radius: Radius.circular(10), clockwise: false)
      ..lineTo(size.width, 10)
      ..lineTo(size.width - 10, 0)
      ..lineTo(size.width - 20, 10)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ArrowPainter extends CustomPainter {
  final CustomClipper<Path> clipper = ArrowClipper();

  @override
  void paint(Canvas canvas, Size size) {
    var path = clipper.getClip(size);
    Paint paint = new Paint()
      ..color = AppTheme.lightGreyColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawShadow(path, AppTheme.shadowColor.withOpacity(0.1), 5, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
