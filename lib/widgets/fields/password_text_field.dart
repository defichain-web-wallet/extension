import 'dart:ui';

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
  final double height;
  final String hint;
  final String label;
  final String? error;
  final Function(String text)? onChanged;
  final Function()? onPressObscure;
  final Function()? onEditComplete;
  final Function(String value)? onSubmitted;
  final String? Function(String?)? validator;
  final bool autofocus;
  final bool isObscure;
  final bool isShowObscureIcon;
  final bool isCaptionShown;
  final bool isOpasity;

  const PasswordTextField({
    Key? key,
    this.status = PasswordStatusList.initial,
    required this.controller,
    required this.hint,
    required this.label,
    this.height = 44,
    this.error,
    this.onChanged,
    this.onPressObscure,
    this.onEditComplete,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.isObscure = false,
    this.isShowObscureIcon = false,
    this.isCaptionShown = true,
    this.isOpasity = false,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  static const String obscureSymbolCharacter = '●';
  static const int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.headline5!.copyWith(
                color: widget.isOpasity
                    ? Colors.white
                    : Theme.of(context).textTheme.headline5!.color,
              ),
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          height: widget.height,
          child: Stack(
            children: [
              if (widget.isOpasity)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 1.5,
                      sigmaY: 1.5,
                    ),
                    child: Container(
                      height: 44,
                      width: double.infinity,
                    ),
                  ),
                ),
              TextFormField(
                autofocus: widget.autofocus,
                maxLines: maxLines,
                obscuringCharacter: obscureSymbolCharacter,
                onFieldSubmitted: widget.onSubmitted,
                textAlignVertical: TextAlignVertical.center,
                obscureText: widget.isObscure,
                onEditingComplete: widget.onEditComplete,
                controller: widget.controller,
                decoration: InputDecoration(
                  errorStyle: TextStyle(
                    backgroundColor: Colors.transparent,
                    color: Colors.pink,
                    fontSize: 10
                  ),
                  hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                  filled: true,
                  fillColor: widget.isOpasity
                      ? AppColors.inputSplashFillColor.withOpacity(0.33)
                      : Theme.of(context).inputDecorationTheme.fillColor,
                  enabledBorder: widget.isOpasity
                      ? Theme.of(context)
                          .inputDecorationTheme
                          .enabledBorder!
                          .copyWith(
                              borderSide: BorderSide(
                            color: AppColors.lavenderPurple.withOpacity(0.33),
                          ))
                      : Theme.of(context).inputDecorationTheme.enabledBorder,
                  focusedBorder:
                      Theme.of(context).inputDecorationTheme.focusedBorder,
                  hintText: widget.hint,
                  hintStyle: widget.isOpasity
                      ? TextStyle(
                          fontSize: passwordField.fontSize,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0,
                        )
                      : TextStyle(
                          fontSize: passwordField.fontSize,
                          letterSpacing: 0,
                        ),
                  suffixIconConstraints:
                      BoxConstraints(minHeight: 24, minWidth: 24),
                  suffixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16.0),
                    child: SuffixIcon(
                      isOpasity: widget.isOpasity,
                      isObscure: widget.isObscure,
                      callback: widget.onPressObscure!,
                    ),
                  ),
                ),
                style: passwordField.copyWith(
                  fontSize: widget.isObscure ? 6 : passwordField.fontSize,
                  letterSpacing: widget.isObscure ? 4 : 0,
                  color: widget.isOpasity
                      ? Colors.white
                      : Theme.of(context).textTheme.headline1!.color!,
                ),
                onChanged: widget.onChanged,
                validator: widget.validator,
              ),
            ],
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
