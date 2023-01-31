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
  final FocusNode? focusNode;
  final String? error;
  final Function(String text)? onChanged;
  final Function()? onPressObscure;
  final Function()? onEditComplete;
  final Function(String)? onSubmitted;
  final Function(String?)? onSaved;
  final bool autofocus;
  final bool isObscure;
  final bool isShowObscureIcon;
  final bool isCaptionShown;

  const PasswordTextField({
    Key? key,
    this.status = PasswordStatusList.initial,
    required this.controller,
    required this.hint,
    required this.label,
    this.focusNode,
    this.error,
    this.onChanged,
    this.onPressObscure,
    this.onEditComplete,
    this.onSubmitted,
    this.onSaved,
    this.autofocus = false,
    this.isObscure = false,
    this.isShowObscureIcon = false,
    this.isCaptionShown = true,
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
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            maxLines: maxLines,
            onFieldSubmitted: widget.onSubmitted,
            textAlignVertical: TextAlignVertical.center,
            obscureText: widget.isObscure,
            onEditingComplete: widget.onEditComplete,
            onSaved: widget.onSaved,
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
            style: passwordField.apply(
              color: Theme.of(context).textTheme.headline1!.color!,
            ),
            onChanged: widget.onChanged,
          ),
        ),
        SizedBox(
          height: 6,
        ),
        if (widget.isCaptionShown)
          CaptionText(
            status: widget.status.toShortString(),
            text: widget.error,
          ),
      ],
    );
  }
}
