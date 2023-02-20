import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrencySelector extends StatefulWidget {
  FiatModel selectedCurrency;
  final void Function(FiatModel) onSelect;
  List<FiatModel> currencies;
  void Function()? onAnotherSelect;
  final bool isBorder;

  CurrencySelector({
    Key? key,
    required this.selectedCurrency,
    required this.onSelect,
    required this.currencies,
    this.onAnotherSelect,
    this.isBorder = false,
  }) : super(key: key);

  @override
  CurrencySelectorState createState() => CurrencySelectorState();
}

class CurrencySelectorState extends State<CurrencySelector> {
  GlobalKey _selectKey = GlobalKey();
  bool _isOpen = false;
  late OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  static const _tileHeight = 46.0;
  LockHelper lockHelper = LockHelper();
  List<String> currencyLogoPathList = [
    'assets/chf_icon.svg',
    'assets/euro_logo.svg',
  ];
  String selectedCurrencyLogoPath = 'assets/chf_icon.svg';

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Your bank account',
            style: Theme.of(context).textTheme.headline2,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    ),
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          key: _selectKey,
          height: _tileHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
              bottomRight:
              _isOpen ? Radius.circular(0) : Radius.circular(10),
              bottomLeft:
              _isOpen ? Radius.circular(0) : Radius.circular(10),
            ),
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: 12.0, bottom: 12.0, left: 22, right: 22),
                        child: SvgPicture.asset(selectedCurrencyLogoPath),
                      ),
                      // SizedBox(width: 16),
                      Text(
                        widget.selectedCurrency.name!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline3!.apply(
                          color: _isOpen
                              ? Theme.of(context)
                              .textTheme
                              .headline3!
                              .color!
                              .withOpacity(0.5)
                              : Theme.of(context)
                              .textTheme
                              .headline3!
                              .color!,
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    _isOpen
                        ? 'assets/arrow_up.svg'
                        : 'assets/arrow_down.svg',
                    color: Theme.of(context).textTheme.button!.color,
                  ),
                ],
              ),
            ),
          ),
        ),
        onTap: () async {
          await lockHelper.provideWithLockChecker(context, () {
            if (!_isOpen && widget.onAnotherSelect != null) {
              widget.onAnotherSelect!();
            }
            _showOverlay();
          });
        },
      ),
    ),
  ]);

  void _showOverlay() async {
    if (_isOpen) {
      hideOverlay();
    } else {
      hideOverlay();
      setState(() {
        _isOpen = true;
      });
      final keyContext = _selectKey.currentContext;
      _overlayState = Overlay.of(keyContext!);
      final box = keyContext.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);

      _overlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
          top: pos.dy + box.size.height,
          left: pos.dx,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: box.size.width,
              height: ((widget.currencies.length) * (_tileHeight + 1)) + 6,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
              child: ListView.separated(
                itemCount: widget.currencies.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        shadowColor: Colors.transparent,
                        primary: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        side: BorderSide(
                          color: Colors.transparent,
                        )),
                    child: Container(
                      height: _tileHeight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 12.0,
                                      bottom: 12.0,
                                      left: 22,
                                      right: 22),
                                  child: SvgPicture.asset(
                                      currencyLogoPathList[index]),
                                ),
                                Text(
                                  widget.currencies[index].name!,
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.currencies[index].name ==
                                      widget.selectedCurrency.name
                                      ? Theme.of(context).textTheme.headline2
                                      : Theme.of(context).textTheme.headline3,
                                ),
                              ],
                            ),
                            SvgPicture.asset(
                              widget.currencies[index].name ==
                                  widget.selectedCurrency.name
                                  ? 'assets/wallet_enable_pink.svg'
                                  : 'assets/wallet_disable.svg',
                              color: AppTheme.pinkColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onPressed: () async {
                      selectedCurrencyLogoPath = currencyLogoPathList[index];
                      widget.selectedCurrency = widget.currencies[index];
                      widget.onSelect(widget.selectedCurrency);
                      hideOverlay();
                    },
                  );
                  // }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1,
                    color: Theme.of(context).textTheme.button!.decorationColor!,
                  );
                },
              ),
            ),
          ),
        );
      });
      _overlayState!.insert(_overlayEntry!);
    }
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (_) {}
    }
    setState(() {
      _isOpen = false;
    });
  }
}