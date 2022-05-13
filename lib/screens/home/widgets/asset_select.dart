import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetSelect extends StatefulWidget {
  final List<String> tokensForSwap;
  String selectedToken;
  final void Function(String) onSelect;

  AssetSelect(
      {Key? key,
      required this.tokensForSwap,
      required this.selectedToken,
      required this.onSelect})
      : super(key: key);

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
  void dispose() {
    hideOverlay();
    super.dispose();
  }

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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: _isOpen ? Radius.circular(0) : Radius.circular(14),
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
                        Text(
                          fixTokenName(widget.selectedToken),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6!.apply(
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
                      ],
                    ),
                    SvgPicture.asset(
                      _isOpen ? 'assets/arrow_up.svg' : 'assets/arrow_down.svg',
                      color: Theme.of(context).textTheme.button!.color,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () async {
            await lockHelper.provideWithLockChecker(context, () => _showOverlay());
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
                    offset: Offset(-3, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
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
                                Text(
                                  fixTokenName(widget.tokensForSwap[index]),
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.tokensForSwap[index] ==
                                          widget.selectedToken
                                      ? Theme.of(context).textTheme.headline6
                                      : Theme.of(context).textTheme.headline5,
                                ),
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

  String fixTokenName(String tokenName) =>
      (tokenName != 'DFI') ? 'd' + tokenName : tokenName;
}
