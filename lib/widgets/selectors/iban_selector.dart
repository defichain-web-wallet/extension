import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/helpers/fiat_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/screens/buy/iban_screen.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class IbanSelector extends StatefulWidget {
  final List<IbanModel> ibanList;
  AssetByFiatModel? asset;
  IbanModel selectedIban;
  void Function()? onAnotherSelect;
  final Widget? routeWidget;
  final bool isShowAsset;
  final bool isBorder;

  IbanSelector({
    Key? key,
    required this.ibanList,
    this.asset,
    required this.selectedIban,
    this.onAnotherSelect,
    this.routeWidget,
    this.isShowAsset = false,
    this.isBorder = false,
  }) : super(key: key);

  @override
  State<IbanSelector> createState() => IbanSelectorState();
}

class IbanSelectorState extends State<IbanSelector> {
  GlobalKey _selectKey = GlobalKey();
  bool _isOpen = false;
  late OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  static const _tileHeight = 46.0;
  LockHelper lockHelper = LockHelper();
  FiatHelper fiatHelper = FiatHelper();

  @override
  Widget build(BuildContext context) => Column(
        children: [
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
                    color: widget.isBorder
                        ? Theme.of(context).dividerColor
                        : Colors.transparent,
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
                              child: Text(
                                'IBAN',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            // SizedBox(width: 16),
                            Text(
                              '${fiatHelper.getIbanFormat(widget.selectedIban.iban!)}',
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.headline3!.apply(
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
        ],
      );

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
              height: (widget.ibanList.length > 5
                      ? (_tileHeight + 6) * 5
                      : (widget.ibanList.length + 1) * (_tileHeight + 1)) +
                  2,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(
                  color: widget.isBorder
                      ? Theme.of(context).dividerColor
                      : Colors.transparent,
                ),
              ),
              child: ListView.separated(
                itemCount: widget.ibanList.length + 1,
                itemBuilder: (context, index) {
                  if (index == widget.ibanList.length) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        shadowColor: Colors.transparent,
                        primary: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                        ),
                        side: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      child: Container(
                        height: _tileHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '+ Add new IBAN',
                            style: Theme.of(context)
                                .textTheme
                                .headline3!
                                .apply(color: AppTheme.pinkColor),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        hideOverlay();
                        if (widget.asset != null) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  IbanScreen(
                                asset: widget.asset!,
                                isNewIban: true,
                                routeWidget: widget.routeWidget,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        Selling(
                                  isNewIban: true,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ));
                        }
                      },
                    );
                  } else {
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
                                    width: 78,
                                    padding: EdgeInsets.only(
                                        top: 12.0,
                                        bottom: 12.0,
                                        left: 22,
                                        right: 22),
                                    child: Text(widget.isShowAsset
                                        ? widget.ibanList[index].fiat!.name!
                                        : ''),
                                  ),
                                  Text(
                                    '${fiatHelper.getIbanFormat(widget.ibanList[index].iban!)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: widget.ibanList[index].id ==
                                            widget.selectedIban.id
                                        ? Theme.of(context).textTheme.headline2
                                        : Theme.of(context).textTheme.headline3,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      onPressed: () async {
                        widget.selectedIban = widget.ibanList[index];
                        FiatCubit fiatCubit =
                            BlocProvider.of<FiatCubit>(context);
                        fiatCubit.changeCurrentIban(widget.selectedIban);
                        hideOverlay();
                      },
                    );
                  }
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
