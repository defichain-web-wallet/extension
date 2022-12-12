import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/fields/password/caption_text.dart';
import 'package:defi_wallet/widgets/fields/suffix_icon.dart';
import 'package:flutter/material.dart';

enum PasswordStatusList { initial, confirm, success, error }

extension ParseToString on PasswordStatusList {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

class PasswordTextField extends StatefulWidget {
  final PasswordStatusList status;
  final TextEditingController controller;
  final String hint;
  final String label;
  final String? error;
  final Function(String text)? onChanged;
  final Function()? onPressObscure;
  final Function()? onEditComplete;
  final Function(String value)? onSubmitted;
  final bool autofocus;
  final bool isObscure;
  final bool isShowObscureIcon;

  const PasswordTextField({
    Key? key,
    this.status = PasswordStatusList.initial,
    required this.controller,
    required this.hint,
    required this.label,
    this.error,
    this.onChanged,
    this.onPressObscure,
    this.onEditComplete,
    this.onSubmitted,
    this.autofocus = false,
    this.isObscure = false,
    this.isShowObscureIcon = false,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  final int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          height: 44,
          child: TextFormField(
            autofocus: widget.autofocus,
            maxLines: maxLines,
            onFieldSubmitted: widget.onSubmitted,
            textAlignVertical: TextAlignVertical.center,
            obscureText: widget.isObscure,
            onEditingComplete: widget.onEditComplete,
            controller: widget.controller,
            decoration: InputDecoration(
              hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              enabledBorder:
                  Theme.of(context).inputDecorationTheme.enabledBorder,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              hintText: widget.hint,
              suffixIconConstraints:
                  BoxConstraints(minHeight: 24, minWidth: 24),
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16.0),
                child: SuffixIcon(
                  isObscure: widget.isObscure,
                  callback: widget.onPressObscure!,
                ),
              ),
            ),
            style: passwordField.apply(color: AppColors.darkTextColor, ),
            onChanged: widget.onChanged,
          ),
        ),
        SizedBox(
          height: 6,
        ),
        CaptionText(
          status: widget.status.toShortString(),
          text: widget.error,
        ),
      ],
    );
  }
}
