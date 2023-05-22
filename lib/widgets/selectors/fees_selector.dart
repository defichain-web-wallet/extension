import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeesSelector extends StatefulWidget {
  final void Function(int) onSelect;
  final List<int> fees;
  final int activeFee;

  FeesSelector({
    Key? key,
    required this.onSelect,
    required this.fees,
    required this.activeFee,
  }) : super(key: key);

  @override
  _FeesSelectorState createState() => _FeesSelectorState();
}

class _FeesSelectorState extends State<FeesSelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  bool _isShowDropdown = false;

  late List<dynamic> _feesList;

  Color getSelectedItemBgColor(String value) {
    if (widget.activeFee.toString() == value) {
      return isDarkTheme()
          ? DarkColors.feesDropdownActiveBgColor
          : LightColors.feesDropdownActiveBgColor;
    } else {
      return Colors.transparent;
    }
  }

  Widget getFeesIcon(String name) {
    return SvgPicture.asset(
      'assets/${name.toLowerCase()}_fee.svg',
      color: isDarkTheme() ? AppColors.white : AppColors.textPrimaryColor,
    );
  }

  @override
  void initState() {
    super.initState();
    List<String> feeNames = ['Slow', 'Medium', 'Fast'];
    _feesList = List<dynamic>.generate(widget.fees.length,
        (index) => {'value': widget.fees[index].toString(), 'name': feeNames[index]});
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);

    return CustomPopupMenu(
      menuOnChange: (b) {
        setState(() {
          _isShowDropdown = b;
        });
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 1,
            color: AppColors.lavenderPurple.withOpacity(0.32),
          ),
        ),
        child: Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/slow_fee.svg',
                          color: isDarkTheme()
                              ? AppColors.white
                              : AppColors.textPrimaryColor,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Slow',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        '${widget.activeFee} sat per byte',
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 16,
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
                RotationTransition(
                  turns: AlwaysStoppedAnimation(_isShowDropdown ? 180 : 0 / 360),
                  child: SizedBox(
                    width: 10,
                    height: 10,
                    child: SvgPicture.asset('assets/icons/arrow_down.svg'),
                  ),
                )
              ],
            )
      ),
      menuBuilder: () => CustomPaint(
        isComplex: true,
        willChange: true,
        painter: ArrowPainter(),
        child: ClipPath(
          clipper: ArrowClipper(),
          child: Container(
                color: isDarkTheme()
                    ? DarkColors.feesDropdownBgColor
                    : LightColors.feesDropdownBgColor,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 6,
                    bottom: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _feesList
                        .map(
                          (item) => MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                controller.hideMenu();

                                widget.onSelect(int.parse(item['value']));
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: getSelectedItemBgColor(item['value']),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: getFeesIcon(item['name']),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      item['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                            fontSize: 16,
                                          ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      '${item['value']} sat per byte',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.3),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
        ),
      ),
      showArrow: false,
      barrierColor: Colors.transparent,
      pressType: PressType.singleClick,
      verticalMargin: 4,
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
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startMargin, 0, width - startMargin, height),
          const Radius.circular(12),
        ),
      )
      ..lineTo(startMargin, s1)
      ..lineTo(startMargin, s2)
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
      ..color = AppColors.lavenderPurple.withOpacity(0.32)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
