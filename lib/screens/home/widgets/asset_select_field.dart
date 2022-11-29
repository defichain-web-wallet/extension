import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssetSelectField extends StatefulWidget {
  final List<String> tokensForSwap;
  String selectedToken;
  final void Function(String) onSelect;
  void Function()? onAnotherSelect;
  bool isFixedWidthText;
  bool isSmallText;
  bool isBorderRadiusAll;
  bool isTopPosition;
  final bool isBorder;
  final String? amountInUsd;
  final accountState;

  AssetSelectField({
    Key? key,
    required this.tokensForSwap,
    required this.selectedToken,
    required this.onSelect,
    this.onAnotherSelect,
    this.isFixedWidthText = false,
    this.isSmallText = false,
    this.isBorderRadiusAll = false,
    this.isTopPosition = false,
    this.isBorder = false,
    this.amountInUsd,
    this.accountState,
  }) : super(key: key);

  @override
  State<AssetSelectField> createState() => AssetSelectFieldState();
}

class AssetSelectFieldState extends State<AssetSelectField> {
  var tokenHelper = TokensHelper();
  GlobalKey _selectKey = GlobalKey();
  bool _isOpen = false;
  late OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  static const _tileHeight = 92.0;
  static const _tileHeightListEl = 46.0;
  LockHelper lockHelper = LockHelper();

  @override
  Widget build(BuildContext context) {
    late List<BalanceModel> balances;
    balances = widget.accountState.activeAccount!.balanceList!
        .where((el) => !el.isHidden!)
        .toList();
    late int balance;
    balances.forEach((element) {
      if (element.token == widget.selectedToken) {
        balance = element.balance!;
      }
    });
    double tokenBalance = convertFromSatoshi(balance);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: Container(
          key: _selectKey,
          height: _tileHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: widget.isBorderRadiusAll
                ? BorderRadius.only(
                    topLeft: _isOpen &&
                            widget.isTopPosition == true &&
                            MediaQuery.of(context).size.width <
                                ScreenSizes.medium
                        ? Radius.circular(0)
                        : Radius.circular(10),
                    topRight: _isOpen &&
                            widget.isTopPosition == true &&
                            MediaQuery.of(context).size.width <
                                ScreenSizes.medium
                        ? Radius.circular(0)
                        : Radius.circular(10),
                    bottomLeft: _isOpen && widget.isTopPosition == false
                        ? Radius.circular(0)
                        : _isOpen &&
                                widget.isTopPosition == true &&
                                MediaQuery.of(context).size.width >
                                    ScreenSizes.medium
                            ? Radius.circular(0)
                            : Radius.circular(10),
                    bottomRight: _isOpen && widget.isTopPosition == false
                        ? Radius.circular(0)
                        : _isOpen &&
                                widget.isTopPosition == true &&
                                MediaQuery.of(context).size.width >
                                    ScreenSizes.medium
                            ? Radius.circular(0)
                            : Radius.circular(10),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft:
                        _isOpen ? Radius.circular(0) : Radius.circular(10),
                  ),
            border: Border.all(color: Colors.transparent),
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    tokenHelper.getImageNameByTokenName(
                                        widget.selectedToken),
                                    height: 24,
                                    width: 24,
                                  ),
                                  SizedBox(width: 16),
                                  if (widget.isFixedWidthText)
                                    TickerText(
                                      child: Text(
                                        SettingsHelper.isBitcoin()
                                            ? widget.selectedToken
                                            : tokenHelper.getTokenWithPrefix(
                                                widget.selectedToken),
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .apply(
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
                                              : tokenHelper.getTokenWithPrefix(
                                                  widget.selectedToken),
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .apply(
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
                                  color:
                                      Theme.of(context).textTheme.button!.color,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available:',
                          style: Theme.of(context).textTheme.headline2!.apply(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color!
                                    .withOpacity(0.5),
                              ),
                        ),
                        Text(
                          '${tokenBalance}',
                          style: Theme.of(context).textTheme.headline2!.apply(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color!
                                    .withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
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
                          ? (_tileHeightListEl + 6) * 5
                          : widget.tokensForSwap.length *
                              (_tileHeightListEl + 1)) +
                      2))
              : (pos.dy + box.size.height),
          left: pos.dx,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: box.size.width,
              height: (widget.tokensForSwap.length > 5
                      ? (_tileHeightListEl + 6) * 5
                      : widget.tokensForSwap.length * (_tileHeightListEl + 1)) +
                  2,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: widget.isTopPosition &&
                        MediaQuery.of(context).size.width < ScreenSizes.medium
                    ? BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                border: Border.all(
                  color: Colors.transparent,
                ),
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
                      height: _tileHeightListEl,
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
