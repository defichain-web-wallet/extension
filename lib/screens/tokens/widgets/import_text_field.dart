import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImportTextField extends StatelessWidget with ThemeMixin {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isNumber;

  ImportTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.headline5,
              softWrap: true,
            ),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : null,
          inputFormatters: isNumber ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(
              RegExp(r'(^-?\d*\.?\,?\d*)'),
            ),
          ] : [],
          decoration: InputDecoration(
            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            hintStyle: passwordField.copyWith(
              color: isDarkTheme()
                  ? DarkColors.hintTextColor
                  : LightColors.hintTextColor,
            ),
            contentPadding: EdgeInsets.only(left: 12),
            hintText: hint,
          ),
          validator: (value) {
            return value == null || value.isEmpty ? "Enter this field" : null;
          },
        ),
      ],
    );
  }
}
