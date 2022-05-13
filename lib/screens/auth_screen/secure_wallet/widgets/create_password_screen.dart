import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/account/account_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/secure_done_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/password_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/auth_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/services/logger_service.dart';

class CreatePasswordScreen extends StatefulWidget {
  final showStep;
  final showDoneScreen;
  final isRecovery;
  final mnemonic;

  CreatePasswordScreen(
      {this.showStep = true,
      this.showDoneScreen = true,
      this.isRecovery = false,
      this.mnemonic = const []});

  @override
  _CreatePasswordScreenState createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final int passwordLength = 8;
  bool isConfirm = false;
  bool isVisiblePassword = true;
  bool isVisibleConfirmPassword = true;
  String password = '';
  String confirmPassword = '';
  String errorHint = 'Must be at least 8 characters';
  bool isFailed = false;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AuthAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      widget.showStep ? '3/3' : '',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create password',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ],
                ),
                StretchBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New password',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      SizedBox(height: 8),
                      PasswordField(
                        obscureText: isVisiblePassword,
                        hintText: 'Enter your Secret password',
                        onChanged: (value) => password = value,
                        onIconPressed: () => setState(
                            () => isVisiblePassword = !isVisiblePassword),
                      ),
                      SizedBox(height: 4),
                      Text(
                        errorHint,
                        style: isFailed
                            ? Theme.of(context).textTheme.headline4!.copyWith(
                                  color: AppTheme.redErrorColor,
                                )
                            : Theme.of(context).textTheme.headline4,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Confirm password',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      SizedBox(height: 8),
                      PasswordField(
                        obscureText: isVisibleConfirmPassword,
                        hintText: 'Confirm password',
                        onChanged: (value) => confirmPassword = value,
                        onIconPressed: () => setState(() =>
                            isVisibleConfirmPassword =
                                !isVisibleConfirmPassword),
                      ),
                      SizedBox(height: 4),
                      Text(
                        errorHint,
                        style: isFailed
                            ? Theme.of(context).textTheme.headline4!.copyWith(
                                  color: AppTheme.redErrorColor,
                                )
                            : Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    StretchBox(
                      child: Row(
                        children: [
                          Checkbox(
                            value: isConfirm,
                            activeColor: AppTheme.pinkColor,
                            onChanged: (newValue) {
                              setState(() {
                                isConfirm = newValue!;
                              });
                            },
                          ),
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
                                onTap: () {
                                  setState(() {
                                    isConfirm = !isConfirm;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 26),
                    StretchBox(
                      child: BlocBuilder<AccountCubit, AccountState>(builder: (context, state) { return PendingButton(
                        'Create password',
                        pendingText: state is AccountRestoreState ? 'Pending... (${state.restored}/${state.needRestore})' : 'Pending...',
                        isCheckLock: false,
                        callback:
                        isConfirm ? (parent) => _loadWallet(parent) : null,
                      );}),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  void _loadWallet(parent) async {
    if (password == confirmPassword && password.length >= passwordLength) {
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      var box = await Hive.openBox(HiveBoxes.client);
      box.put(HiveNames.password, stringToBase64.encode(password));

      parent.emitPending(true);

      Future.delayed(const Duration(milliseconds: 500), () async {
        if (widget.isRecovery) {
          try {
            await accountCubit.restoreAccount(widget.mnemonic, password);
            LoggerService.invokeInfoLogg('user was recover wallet');
          } catch (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Something error',
                  style: Theme.of(context).textTheme.headline5,
                ),
                backgroundColor:
                    Theme.of(context).snackBarTheme.backgroundColor,
              ),
            );
          }
        } else {
          if (widget.mnemonic.length != 0) {
            await accountCubit.createAccount(widget.mnemonic, password);
            LoggerService.invokeInfoLogg('user created new wallet');
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                widget.showDoneScreen ? SecureDoneScreen() : HomeScreen(isLoadTokens: true,),
          ),
        );

        parent.emitPending(false);
      });
    } else if (password != confirmPassword) {
      setState(() {
        errorHint = 'Password does not match';
        isFailed = true;
      });
      parent.emitPending(false);
    } else {
      setState(() {
        errorHint = 'Must be at least 8 characters';
        isFailed = true;
      });
      parent.emitPending(false);
    }
  }
}
