import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  bool isPasswordObscure = true;
  bool isConfirmObscure = true;

  PasswordStatusList passwordStatus = PasswordStatusList.initial;
  PasswordStatusList confirmStatus = PasswordStatusList.initial;

  bool isEnabledCheckbox = true;
  bool isEnable = false;
  bool isConfirm = false;

  bool _enableBtn = false;
  String? confirmErrorMessage;
  String? passwordErrorMessage;

  static const String matchErrorMessage = 'Both passwords should match';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(builder: (
      BuildContext context,
      bool isFullScreen,
      TransactionState txState,
    ) {
      return Scaffold(
        appBar: WelcomeAppBar(),
        body: Container(
          padding: authPaddingContainer,
          child: Form(
            key: _formKey,
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Text(
                          'Create password',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        SizedBox(
                          height: 48,
                        ),
                        PasswordTextField(
                          controller: password,
                          hint: 'Your password',
                          label: 'Password',
                          status: passwordStatus,
                          error: passwordErrorMessage,
                          isShowObscureIcon: true,
                          isObscure: isPasswordObscure,
                          onChanged: (String value) {
                            // TODO: try move to mixin
                            if (value.length < 8) {
                              setState(() {
                                passwordStatus = PasswordStatusList.error;
                                _enableBtn = false;
                              });
                            } else {
                              if (value == confirm.text && confirm.text.isNotEmpty) {
                                setState(() {
                                  passwordStatus = PasswordStatusList.success;
                                  _enableBtn = true;
                                });
                              } else if (value != confirm.text && confirm.text.isNotEmpty) {
                                setState(() {
                                  passwordStatus = PasswordStatusList.error;
                                  passwordErrorMessage = matchErrorMessage;
                                  _enableBtn = false;
                                });
                              } else {
                                setState(() {
                                  passwordStatus = PasswordStatusList.success;
                                  passwordErrorMessage = null;
                                  _enableBtn = true;
                                });
                              }
                            }
                          },
                          onPressObscure: () {
                            setState(
                                () => isPasswordObscure = !isPasswordObscure);
                          },
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        PasswordTextField(
                          controller: confirm,
                          hint: 'Confirm password',
                          label: 'Confirm Password',
                          status: confirmStatus,
                          isShowObscureIcon: true,
                          error: confirmErrorMessage,
                          isObscure: isConfirmObscure,
                          onChanged: (String value) {
                            // TODO: try move to mixin
                            if (value.length < 8) {
                              setState(() {
                                confirmStatus = PasswordStatusList.error;
                                confirmErrorMessage = null;
                                _enableBtn = false;
                              });
                            } else if (value != password.text) {
                              setState(() {
                                confirmStatus = PasswordStatusList.error;
                                confirmErrorMessage = matchErrorMessage;
                                _enableBtn = false;
                              });
                            } else {
                              setState(() {
                                confirmStatus = PasswordStatusList.success;
                                confirmErrorMessage = null;
                                _enableBtn = true;
                              });
                            }
                          },
                          onPressObscure: () {
                            setState(
                                () => isConfirmObscure = !isConfirmObscure);
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                                value: isConfirm,
                                activeColor: AppColors.pinkColor,
                                onChanged: isEnabledCheckbox
                                    ? (newValue) {
                                        setState(
                                          () {
                                            isConfirm = newValue!;
                                            setState(() {});
                                          },
                                        );
                                      }
                                    : null),
                            Flexible(
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'I understand that this password cannot be recovered.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: isEnabledCheckbox
                                      ? () {
                                          setState(
                                            () {
                                              isConfirm = !isConfirm;
                                            },
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        NewPrimaryButton(
                          title: 'Create password',
                          callback: _enableBtn && isConfirm ? () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  PasswordScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ) : null,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}