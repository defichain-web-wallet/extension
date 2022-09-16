import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecorationTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusModel? focusModel;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool isBorder;
  final void Function()? hideOverlay;

  const DecorationTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.focusModel,
    this.onChanged,
    this.suffixIcon,
    this.isBorder = false,
    this.hideOverlay,
  }) : super(key: key);

  @override
  _DecorationTextFieldState createState() => _DecorationTextFieldState();
}

class _DecorationTextFieldState extends State<DecorationTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
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
          onFocusChange: (focus) =>
              setState(() => widget.focusModel!.isFocus = focus),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: Theme.of(context).cardColor,
            ),
            child: TextField(
              textAlign: TextAlign.center,
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
                  borderSide: BorderSide(color: AppTheme.pinkColor),
                ),
                suffixIcon: widget.suffixIcon ?? null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: widget.onChanged ?? null,
              controller: widget.controller,
              focusNode: widget.focusNode,
              onTap: widget.hideOverlay,
            ),
          ),
        ),
      ),
    );
  }
}
