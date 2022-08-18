import 'dart:async';

import 'package:defi_wallet/screens/address_book/add_new_address.dart';
import 'package:defi_wallet/screens/address_book/widgets/address_book_buttons.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class AddressBookCard extends StatefulWidget {
  final String name;
  final String address;
  final int id;
  final Function() editCallback;
  final Function() deleteCallback;

  const AddressBookCard({
    Key? key,
    required this.name,
    required this.address,
    required this.id,
    required this.editCallback,
    required this.deleteCallback,
  }) : super(key: key);

  @override
  State<AddressBookCard> createState() => _AddressBookCardState();
}

class _AddressBookCardState extends State<AddressBookCard> {
  late Color? textColorHover;
  Timer? timer;
  String tooltipMessage = "Copy to clipboard";
  bool isShowTooltip = false;
  bool isFirstBuild = true;
  double maxNameWidth = 250;
  double x = 0.0;
  double y = 0.0;

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      textColorHover = Theme.of(context).textTheme.headline4!.color!;
      isFirstBuild = !isFirstBuild;
    }
    return Card(
      margin: EdgeInsets.only(top: 0, bottom: 10, left: 0, right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: maxNameWidth,
                  child: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SimpleTooltip(
                  animationDuration: Duration(seconds: 1),
                  show: isShowTooltip,
                  tooltipDirection: TooltipDirection.down,
                  arrowTipDistance: 0,
                  arrowLength: 10,
                  arrowBaseWidth: 20,
                  borderWidth: 0,
                  ballonPadding: const EdgeInsets.all(0),
                  backgroundColor: AppTheme.pinkColor,
                  customShadows: [
                    const BoxShadow(
                        color: Colors.white, blurRadius: 0, spreadRadius: 0),
                  ],
                  content: Text(
                    tooltipMessage,
                    style: TextStyle(
                      backgroundColor: AppTheme.pinkColor,
                      color: Colors.white,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                      fontFamily: 'IBM Plex Sans',
                    ),
                  ),
                  child: MouseRegion(
                    onHover: _updateLocation,
                    onExit: _updateLocationExit,
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => copyAddress(widget.address),
                      child: Text(
                        widget.address,
                        style: Theme.of(context).textTheme.headline4!.apply(
                              color: textColorHover,
                              fontSizeFactor: 0.9,
                              fontFamily: 'IBM Plex Sans',
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              AddressBookButtons(
                editCallback: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AddNewAddress(
                      name: widget.name,
                      address: widget.address,
                      id: widget.id,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
                deleteCallback: widget.deleteCallback,
              ),
            ],
          )
        ],
      ),
    );
  }

  copyAddress(address) async {
    setState(() => isShowTooltip = false);

    await Clipboard.setData(ClipboardData(text: address));

    setState(() {
      tooltipMessage = "Address copied!";
      isShowTooltip = true;
    });
  }

  void _updateLocation(PointerEvent details) => setState(() {
        textColorHover = Color(0xFFFF00A3);
        isShowTooltip = true;
        x = details.position.dx;
        y = details.position.dy;
      });

  void _updateLocationExit(PointerEvent details) => setState(() {
        textColorHover = Theme.of(context).textTheme.headline4!.color!;
        isShowTooltip = false;
        Timer(Duration(seconds: 1), () => tooltipMessage = "Copy to clipboard");
      });
}
