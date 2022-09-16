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
  final void Function()? hideOverlay;

  const DecorationTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.focusModel,
    this.onChanged,
    this.suffixIcon,
    this.hideOverlay,
  }) : super(key: key);

  @override
  _DecorationTextFieldState createState() => _DecorationTextFieldState();
}

class _DecorationTextFieldState extends State<DecorationTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: SettingsHelper.settings.theme == 'Light' ? 46 : 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: FocusScope(
        child: Focus(
          onFocusChange: (focus) =>
              setState(() => widget.focusModel!.isFocus = focus),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.focusModel!.isFocus
                      ? AppTheme.pinkColor
                      : Theme.of(context).textTheme.button!.decorationColor!,
                  spreadRadius: 1,
                  blurRadius: 0,
                  offset: Offset(0, 0), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(
                    SettingsHelper.settings.theme == 'Light' ? 16 : 15),
                bottomRight: Radius.circular(
                    SettingsHelper.settings.theme == 'Light' ? 16 : 15),
              ),
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
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hoverColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  borderSide: BorderSide(color: Colors.transparent),
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
