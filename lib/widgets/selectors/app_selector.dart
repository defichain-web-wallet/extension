import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> list = <String>['USD', 'EUR', 'BTC'];

class AppSelector extends StatefulWidget {
  final List<String> items;
  final void Function(String value) onSelect;

  AppSelector({
    Key? key,
    required this.items,
    required this.onSelect,
  }) : super(key: key);

  @override
  _AppSelectorState createState() => _AppSelectorState();
}

class _AppSelectorState extends State<AppSelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();
  bool isOpenAppSelector = false;

  final List<dynamic> menuItems = [
    {'name': 'USD', 'icon': 'assets/currencies/usd.svg'},
    {'name': 'EUR', 'icon': 'assets/currencies/eur.svg'},
    {'name': 'BTC', 'icon': 'assets/currencies/btc.svg'},
  ];

  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton<String>(
          dropdownColor: isDarkTheme()
              ? DarkColors.dropdownBgColor
              : LightColors.dropdownBgColor,
          value: dropdownValue,
          elevation: 3,
          icon: Visibility(visible: false, child: Icon(Icons.arrow_back),),
          style: const TextStyle(color: Colors.green),
          onChanged: (String? value) {
            widget.onSelect(value!);
            setState(() {
              dropdownValue = value;
            });
          },
          borderRadius: BorderRadius.circular(20.0),
          selectedItemBuilder: (BuildContext context) {
            return list.map<Widget>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  width: 116,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .headline5,
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
              );
            }).toList();
          },
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Container(
                width: 116,
                padding: const EdgeInsets.all(0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/currencies/${value.toLowerCase()}.svg',
                          width: 16,
                          height: 16,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headline5,
                        ),
                      ],
                    ),
                    if (dropdownValue == value)
                      SvgPicture.asset(
                        'assets/icons/check_icon.svg',
                        width: 16,
                        height: 16,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
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
