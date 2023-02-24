import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrencySelector extends StatefulWidget {
  final FiatModel selectedCurrency;
  final List<FiatModel> currencies;
  final void Function(FiatModel) onSelect;

  CurrencySelector({
    Key? key,
    required this.onSelect,
    required this.selectedCurrency,
    required this.currencies,
  }) : super(key: key);

  @override
  _CurrencySelectorState createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  bool isShowAllNetworks = true;
  NetworkTabs activeTab = NetworkTabs.all;
  String currentNetworkItem = 'DefiChain Mainnet';
  bool _isShowDropdown = false;
  List<String> currencyLogoPathList = [
    'assets/currencies/eur.svg',
    'assets/currencies/eur.svg',
  ];
  String selectedCurrencyLogoPath = 'assets/currencies/eur.svg';

  getNetworkName() {
    SettingsModel settings = SettingsHelper.settings;
    String network = settings.network!;
    if (network == 'mainnet') {
      return (settings.isBitcoin!) ? 'Bitcoin Mainnet' : 'DefiChain Mainnet';
    } else {
      return (settings.isBitcoin!) ? 'Bitcoin Testnet' : 'DefiChain Testnet';
    }
  }

  @override
  Widget build(BuildContext context) {
    double arrowRotateDeg = _isShowDropdown ? 180 : 0;

    double horizontalMargin = menuHelper.getHorizontalMargin(context);
    NetworkCubit networkCubit = BlocProvider.of<NetworkCubit>(context);

    return CustomPopupMenu(
      menuOnChange: (b) {
        setState(() {
          _isShowDropdown = b;
        });
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.portage.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: SvgPicture.asset(
                      'assets/currencies/${widget.selectedCurrency.name!.toLowerCase()}.svg'),
                ),
                SizedBox(width: 8),
                Text(
                  widget.selectedCurrency.name!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        color: _isShowDropdown
                            ? Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.5)
                            : Theme.of(context).textTheme.headline5!.color!,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
            RotationTransition(
              turns: AlwaysStoppedAnimation(arrowRotateDeg / 360),
              child: SizedBox(
                width: 10,
                height: 10,
                child: SvgPicture.asset(
                  'assets/icons/arrow_down.svg',
                ),
              ),
            ),
          ],
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
            child: BlocBuilder<NetworkCubit, NetworkState>(
              builder: (context, networkState) {
                return Container(
                  color: isDarkTheme() ? Theme.of(context).inputDecorationTheme.fillColor : LightColors.networkDropdownBgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                    ),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widget.currencies
                            .map(
                              (item) => Column(
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        controller.hideMenu();
                                        widget.onSelect(item);
                                      },
                                      child: Container(
                                        height: 44,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: SvgPicture.asset(
                                                'assets/currencies/${item.name!.toLowerCase()}.svg',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              item.name!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
                                            )
                                          ],
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
                );
              },
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
