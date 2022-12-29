import 'package:defi_wallet/widgets/selectors/asset/asset_header_selector.dart';
import 'package:defi_wallet/widgets/selectors/asset/asset_item_selector.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';

class AssetSelector extends StatefulWidget {
  final void Function(TokensModel) onSelect;
  final List<TokensModel> assets;
  final TokensModel selectedAsset;

  AssetSelector({
    Key? key,
    required this.onSelect,
    required this.assets,
    required this.selectedAsset,
  }) : super(key: key);

  @override
  _AssetSelectorState createState() => _AssetSelectorState();
}

class _AssetSelectorState extends State<AssetSelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  bool _isShowDropdown = false;
  late String _currentAssetCode;

  @override
  void initState() {
    _currentAssetCode = widget.assets[0].symbol!;
    super.initState();
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
        width: 100,
        height: 38,
        child: AssetHeaderSelector(
          assetCode: widget.selectedAsset.symbol!,
          isShown: _isShowDropdown,
        ),
      ),
      menuBuilder: () => Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 4,
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: ArrowPainter(),
          child: ClipPath(
            clipper: ArrowClipper(),
            child: Container(
              color: isDarkTheme()
                  ? DarkColors.networkDropdownBgColor
                  : LightColors.networkDropdownBgColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: 344,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      child: Text(
                        'Pick the currency you want to change from',
                        style:
                        Theme.of(context).textTheme.headline6!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .textTheme
                              .headline6!
                              .color!
                              .withOpacity(0.3),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 210,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...List<Widget>.generate(
                              widget.assets.length,
                                  (index) {
                                return AssetItemSelector(
                                  assetCode: widget.assets[index].symbol!,
                                  assetName: widget.assets[index].name!,
                                  isActive: widget.selectedAsset.symbol! ==
                                      widget.assets[index].symbol!,
                                  onChange: () {
                                    widget.onSelect(widget.assets[index]);
                                    controller.hideMenu();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startMargin, 0, width - startMargin, height),
          const Radius.circular(16),
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
      ..color = AppColors.white.withOpacity(0.04)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
