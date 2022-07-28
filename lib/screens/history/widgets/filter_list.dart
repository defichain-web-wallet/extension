import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterList extends StatefulWidget {
  final void Function() onSelect;

  FilterList({Key? key, required this.onSelect}) : super(key: key);

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  final List<dynamic> menuItems = [
    {'name': 'arrow'},
    {'name': 'all'},
    {'name': 'send'},
    {'name': 'receive'},
    {'name': 'swap'},
    {'name': 'add liquidity'},
    {'name': 'remove liquidity'},
    {'name': 'utxos to account'},
    {'name': 'account to utxos'},
  ];

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);

    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      if (state.status == AccountStatusList.success) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        return CustomPopupMenu(
          menuOnChange: (b) => widget.onSelect(),
          child: Icon(
            Icons.filter_list,
            color: controller.menuIsShowing
                ? AppTheme.pinkColor
                : Theme.of(context).appBarTheme.actionsIconTheme!.color,
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
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        controller.hideMenu();
                                        accountCubit.setHistoryFilterBy(item['name']);
                                      },
                                      child: Container(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    item['name'],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4,
                                                  ),
                                                  (state.historyFilterBy ==
                                                          item['name'])
                                                      ? Icon(
                                                          Icons.done,
                                                          color:
                                                              Color(0xffFF00A3),
                                                        )
                                                      : Container()
                                                ],
                                              )),
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
          controller: controller,
        );
      } else {
        return Container();
      }
    });
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
    canvas.drawShadow(path, Colors.grey.withOpacity(0.5), 5, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
