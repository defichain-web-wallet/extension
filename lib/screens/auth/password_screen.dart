import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordScreen extends StatefulWidget {
  final Function(String password) onSubmitted;
  final bool isShownProgressBar;

  const PasswordScreen({
    Key? key,
    required this.onSubmitted,
    this.isShownProgressBar = true,
  }) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  FocusNode checkBoxFocusNode = FocusNode();
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
  void initState() {
    checkBoxFocusNode.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(builder: (
      BuildContext context,
      bool isFullScreen,
      TransactionState txState,
    ) {
      return Scaffold(
        appBar: WelcomeAppBar(
          progress: widget.isShownProgressBar ? 0.3 : 0,
        ),
        body: Container(
          padding: authPaddingContainer,
          child: Center(
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
                            height: 43,
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
                                if (value == confirm.text &&
                                    confirm.text.isNotEmpty) {
                                  setState(() {
                                    passwordStatus = PasswordStatusList.success;
                                    confirmStatus = PasswordStatusList.success;
                                    _enableBtn = true;
                                  });
                                } else if (value != confirm.text &&
                                    confirm.text.isNotEmpty) {
                                  setState(() {
                                    confirmStatus = PasswordStatusList.error;
                                    confirmErrorMessage = matchErrorMessage;
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: DefiCheckbox(
                            width: boxSmallWidth,
                            callback: (val) {
                              setState(() {
                                isConfirm = val!;
                              });
                            },
                            value: isConfirm,
                            focusNode: checkBoxFocusNode,
                            isShowLabel: false,
                            textWidget: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text:
                                      'I understand that nobody can recover this password for me.',
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ]),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Container(
                          width: isFullScreen ? buttonFullWidth : buttonSmallWidth,
                          child: BlocBuilder<AccountCubit, AccountState>(
                            builder: (context, state) {
                              return PendingButton(
                                'Create password',
                                pendingText: state.status ==
                                        AccountStatusList.restore
                                    ? 'Processing (${state.restored}/${state.needRestore})'
                                    : 'Processing...',
                                isCheckLock: false,
                                callback: _enableBtn && isConfirm
                                    ? (parent) async {
                                        parent.emitPending(true);
                                        await widget.onSubmitted(password.text);
                                        parent.emitPending(false);
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
