import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecorationTextFieldNew extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusModel? focusModel;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool isBorder;
  final String amountInUsd;
  final String selectedAsset;
  final void Function()? hideOverlay;

  const DecorationTextFieldNew({
    Key? key,
    this.controller,
    this.focusNode,
    this.focusModel,
    this.onChanged,
    this.suffixIcon,
    this.isBorder = false,
    this.amountInUsd = '0.0',
    this.selectedAsset = 'DFI',
    this.hideOverlay,
  }) : super(key: key);

  @override
  _DecorationTextFieldNewState createState() => _DecorationTextFieldNewState();
}

class _DecorationTextFieldNewState extends State<DecorationTextFieldNew> {
  double _containerHeight = 94;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    String currency = SettingsHelper.settings.currency!;
    return Container(
      height: _containerHeight,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: FocusScope(
        child: Focus(
          onFocusChange: (focus) => setState(
            () {
              widget.focusModel!.isFocus = focus;
              _focus = focus;
            },
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border.all(
                color: widget.focusModel!.isFocus
                    ? AppTheme.pinkColor
                    : Colors.transparent,
              ),
              color: Theme.of(context).cardColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextField(
                        textAlign: TextAlign.right,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^-?\d*\.?d*\,?\d*)')),
                        ],
                        style: Theme.of(context).textTheme.button,
                        decoration: InputDecoration(
                          filled: false,
                          fillColor: Theme.of(context).cardColor,
                          hoverColor: Colors.transparent,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          suffixText: widget.selectedAsset,
                          contentPadding:
                              const EdgeInsets.only(left: 10),
                        ),
                        onChanged: widget.onChanged ?? null,
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        onTap: widget.hideOverlay,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.amountInUsd} $currency',
                              style:
                                  Theme.of(context).textTheme.headline4!.apply(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .color!
                                            .withOpacity(0.5),
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _focusChange(bool focus) {}
}
