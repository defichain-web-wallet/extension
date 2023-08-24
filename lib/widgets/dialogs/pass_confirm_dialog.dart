import 'dart:ui';

import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/services/password_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PassConfirmDialog extends StatefulWidget {
  final Function(String) onSubmit;
  final Function()? onCancel;
  final String message;
  final context;

  const PassConfirmDialog({
    Key? key,
    required this.onSubmit,
    this.onCancel,
    this.context,
    this.message = 'Please confirm the transaction\nby entering your password',
  }) : super(key: key);

  @override
  State<PassConfirmDialog> createState() => _PassConfirmDialogState();
}

class _PassConfirmDialogState extends State<PassConfirmDialog>
    with ThemeMixin, SnackBarMixin {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordObscure = true;
  bool isEnable = true;
  bool isValid = true;
  bool isVisiblePasswordField = true;
  String password = '';
  bool isFailed = false;
  GlobalKey globalKey = GlobalKey();
  TextEditingController _passwordController = TextEditingController();
  FocusNode confirmFocusNode = FocusNode();

  @override
  void dispose() {
    confirmFocusNode.dispose();
    _passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BlocBuilder<WalletCubit, WalletState>(builder: (context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: AlertDialog(
            backgroundColor: isDarkTheme()
                ? DarkColors.drawerBgColor
                : LightColors.drawerBgColor,
            shape: RoundedRectangleBorder(
              side: isDarkTheme()
                  ? BorderSide(color: DarkColors.drawerBorderColor)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: EdgeInsets.all(24),
            actionsPadding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 14,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 104,
                    child: AccentButton(
                      callback: () {
                        if (widget.onCancel != null) {
                          widget.onCancel!();
                        }
                        Navigator.pop(context);
                      },
                      label: 'Cancel',
                    ),
                  ),
                  NewPrimaryButton(
                    focusNode: confirmFocusNode,
                    width: 104,
                    title: 'Confirm',
                    callback: () {
                      _restoreWallet(context);
                    },
                  ),
                ],
              ),
            ],
            contentPadding: EdgeInsets.only(
              top: 16,
              bottom: 0,
              left: 16,
              right: 16,
            ),
            content: Stack(
              children: [
                Container(
                  width: 312,
                  height: 203,
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onCancel != null) {
                                  widget.onCancel!();
                                }
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.5),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Confirmation',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .color),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.message,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .color!
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            PasswordTextField(
                              autofocus: true,
                              height: 71,
                              controller: _passwordController,
                              status: PasswordStatusList.initial,
                              hint: 'Your password',
                              label: 'Password',
                              isShowObscureIcon: true,
                              isCaptionShown: false,
                              isObscure: isPasswordObscure,
                              onChanged: (String value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              onPressObscure: () {
                                setState(() =>
                                    isPasswordObscure = !isPasswordObscure);
                              },
                              validator: (val) {
                                if (!PasswordService.targetRegExp
                                    .hasMatch(val!)) {
                                  String disallowedCharacters =
                                      PasswordService()
                                          .getDisallowedCharacters(password);

                                  return 'Character(s) \'$disallowedCharacters\' are not allowed. '
                                      'Only english alphabet characters are allowed in the password.';
                                }
                                return isValid ? null : "Incorrect password";
                              },
                              onSubmitted: (val) {
                                confirmFocusNode.requestFocus();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          }
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.5),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future _confirm(BuildContext context) async {
    await PasswordService().handleCorrectAndRun(
      widget.context,
      _passwordController.text,
      () async {
        await _restoreWallet(context);
      },
    );
  }

  Future _restoreWallet(context) async {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    setState(() {
      isValid = true;
      _formKey.currentState!.validate();
      isFailed = false;
      isEnable = false;
    });
    if (walletCubit.validatePassword(password)) {
      setState(() {
        isValid = true;
        _formKey.currentState!.validate();
      });
      widget.onSubmit(_passwordController.text);
      Navigator.pop(context);
    } else {
      setState(() {
        isValid = false;
        _formKey.currentState!.validate();
        isFailed = true;
        isEnable = true;
      });
    }
  }
}
