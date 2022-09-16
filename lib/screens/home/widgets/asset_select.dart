import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetSelect extends StatefulWidget {
  final List<String> tokensForSwap;
  String selectedToken;
  final void Function(String) onSelect;
  void Function()? onAnotherSelect;
  bool isFixedWidthText;
  bool isSmallText;
  bool isBorderRadiusAll;
  bool isTopPosition;

  AssetSelect({
    Key? key,
    required this.tokensForSwap,
    required this.selectedToken,
    required this.onSelect,
    this.onAnotherSelect,
    this.isFixedWidthText = false,
    this.isSmallText = false,
    this.isBorderRadiusAll = false,
    this.isTopPosition = false,
  }) : super(key: key);

  @override
  State<AssetSelect> createState() => AssetSelectState();
}

class AssetSelectState extends State<AssetSelect> {
  var tokenHelper = TokensHelper();
  GlobalKey _selectKey = GlobalKey();
  bool _isOpen = false;
  late OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  static const _tileHeight = 46.0;
  LockHelper lockHelper = LockHelper();

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Container(
            key: _selectKey,
            height: _tileHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor.withOpacity(0.5),
                  blurRadius: 5,
                  offset: Offset(-3, 3),
                )
              ],
              borderRadius: widget.isBorderRadiusAll
                  ? BorderRadius.only(
                      topLeft: _isOpen &&
                              widget.isTopPosition == true &&
                              MediaQuery.of(context).size.width <
                                  ScreenSizes.medium
                          ? Radius.circular(0)
                          : Radius.circular(14),
                      topRight: _isOpen &&
                              widget.isTopPosition == true &&
                              MediaQuery.of(context).size.width <
                                  ScreenSizes.medium
                          ? Radius.circular(0)
                          : Radius.circular(14),
                      bottomLeft: _isOpen && widget.isTopPosition == false
                          ? Radius.circular(0)
                          : _isOpen && widget.isTopPosition == true && MediaQuery.of(context).size.width >
                          ScreenSizes.medium
                              ? Radius.circular(0)
                              : Radius.circular(14),
                      bottomRight: _isOpen && widget.isTopPosition == false
                          ? Radius.circular(0)
                          : _isOpen && widget.isTopPosition == true && MediaQuery.of(context).size.width >
                          ScreenSizes.medium
                          ? Radius.circular(0)
                          : Radius.circular(14),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft:
                          _isOpen ? Radius.circular(0) : Radius.circular(14),
                    ),
              border: Border.all(
                  color: Theme.of(context).textTheme.button!.decorationColor!),
            ),
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          tokenHelper
                              .getImageNameByTokenName(widget.selectedToken),
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(width: 16),
                        if(widget.isFixedWidthText)
                          TickerText(
                            child: Text(
                              SettingsHelper.isBitcoin()
                                  ? widget.selectedToken
                                  : tokenHelper
                                      .getTokenWithPrefix(widget.selectedToken),
                              overflow: TextOverflow.ellipsis,
                              style:
                              Theme.of(context).textTheme.headline6!.apply(
                                color: _isOpen
                                    ? Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color!
                                    .withOpacity(0.5)
                                    : Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color!,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 70,
                            child: TickerText(
                              child: Text(
                                SettingsHelper.isBitcoin()
                                    ? widget.selectedToken
                                    : tokenHelper
                                    .getTokenWithPrefix(widget.selectedToken),
                                overflow: TextOverflow.ellipsis,
                                style:
                                Theme.of(context).textTheme.headline6!.apply(
                                  color: _isOpen
                                      ? Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color!
                                      .withOpacity(0.5)
                                      : Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color!,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    if (widget.tokensForSwap.isNotEmpty)
                      SvgPicture.asset(
                        _isOpen
                            ? (widget.isTopPosition
                                ? MediaQuery.of(context).size.width <
                                        ScreenSizes.medium
                                    ? 'assets/arrow_down.svg'
                                    : 'assets/arrow_up.svg'
                                : 'assets/arrow_up.svg')
                            : (widget.isTopPosition
                                ? MediaQuery.of(context).size.width <
                                        ScreenSizes.medium
                                    ? 'assets/arrow_up.svg'
                                    : 'assets/arrow_down.svg'
                                : 'assets/arrow_down.svg'),
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
              if (widget.tokensForSwap.isNotEmpty) {
                _showOverlay();
              }
            });
          },
        ),
      );

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
          top: widget.isTopPosition &&
                  MediaQuery.of(context).size.width < ScreenSizes.medium
              ? (pos.dy -
                  ((widget.tokensForSwap.length > 5
                          ? (_tileHeight + 6) * 5
                          : widget.tokensForSwap.length * (_tileHeight + 1)) +
                      2))
              : (pos.dy + box.size.height),
          left: pos.dx,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: box.size.width,
              height: (widget.tokensForSwap.length > 5
                      ? (_tileHeight + 6) * 5
                      : widget.tokensForSwap.length * (_tileHeight + 1)) +
                  2,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowColor.withOpacity(0.5),
                    blurRadius: 5,
                    offset:
                        widget.isTopPosition && MediaQuery.of(context).size.width <
                            ScreenSizes.medium ? Offset(-3, -3) : Offset(-3, 3),
                  ),
                ],
                borderRadius: widget.isTopPosition &&
                        MediaQuery.of(context).size.width < ScreenSizes.medium
                    ? BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      )
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                border: Border.all(
                    color:
                        Theme.of(context).textTheme.button!.decorationColor!),
              ),
              child: ListView.separated(
                itemCount: widget.tokensForSwap.length,
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
                        padding: const EdgeInsets.only(left: 16, right: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  tokenHelper.getImageNameByTokenName(
                                      widget.tokensForSwap[index]),
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 16),
                                if (widget.isFixedWidthText)
                                  TickerText(
                                    child: Text(
                                        tokenHelper.getTokenWithPrefix(
                                            widget.tokensForSwap[index]),
                                        overflow: TextOverflow.ellipsis,
                                        style: widget.tokensForSwap[index] ==
                                            widget.selectedToken
                                            ? Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            : Theme.of(context)
                                            .textTheme
                                            .headline5!),
                                  )
                                else
                                  Container(
                                    width: 65,
                                    child: TickerText(
                                      child: Text(
                                          tokenHelper.getTokenWithPrefix(
                                              widget.tokensForSwap[index]),
                                          overflow: TextOverflow.ellipsis,
                                          style: widget.tokensForSwap[index] ==
                                              widget.selectedToken
                                              ? Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              : Theme.of(context)
                                              .textTheme
                                              .headline5!),
                                    ),
                                  )
                              ],
                            ),
                            SvgPicture.asset(
                              widget.tokensForSwap[index] ==
                                      widget.selectedToken
                                  ? 'assets/wallet_enable_pink.svg'
                                  : 'assets/wallet_disable.svg',
                              color: AppTheme.pinkColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onPressed: () async {
                      widget.selectedToken = widget.tokensForSwap[index];
                      widget.onSelect(widget.selectedToken);
                      hideOverlay();
                    },
                  );
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
}
