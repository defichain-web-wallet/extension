import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSelector extends StatefulWidget {
  final void Function(String value) onSelect;

  AppSelector({Key? key, required this.onSelect}) : super(key: key);

  @override
  _AppSelectorState createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  final List<dynamic> menuItems = [
    {'name': 'USD', 'icon': 'assets/currencies/usd.svg'},
    {'name': 'EUR', 'icon': 'assets/currencies/eur.svg'},
    {'name': 'BTC', 'icon': 'assets/currencies/btc.svg'},
  ];

  late String activeItem;

  @override
  void initState() {
    activeItem = menuItems[1]['name'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);
    return CustomPopupMenu(
      menuOnChange: (b) => widget.onSelect(activeItem),
      child: Container(
        width: 116,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              activeItem,
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(
              width: 8,
            ),
            SvgPicture.asset(
              'assets/icons/arrow_down.svg',
              width: 6,
              height: 6,
            )
          ],
        ),
      ),
      menuBuilder: () => CustomPaint(
        child: ClipPath(
          clipper: ArrowClipper(),
          child: Container(
            width: 116,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: menuItems
                  .map(
                    (item) => Column(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              controller.hideMenu();
                              setState(() {
                                activeItem = item['name'];
                              });
                            },
                            child: Container(
                              height: 40,
                              child: Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 20),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              if (activeItem != 'arrow')
                                                SvgPicture.asset(
                                                  item['icon'],
                                                  width: 16,
                                                  height: 16,
                                                ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                item['name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (activeItem == item['name'])
                                          SvgPicture.asset(
                                            'assets/icons/check_icon.svg',
                                            width: 16,
                                            height: 16,
                                          )
                                      ],
                                    )),
                              ),
                            ),
                          ),
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
      controller: controller,
    );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double startMargin = 0;

    final double s1 = height * 0.3;
    final double s2 = height * 0.7;
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(startMargin, 0, width - startMargin, height),
          const Radius.circular(16)))
      ..lineTo(startMargin, s1)
      ..lineTo(startMargin, s2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
