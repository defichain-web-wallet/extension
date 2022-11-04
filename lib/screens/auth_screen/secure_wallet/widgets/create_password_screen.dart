import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/secure_done_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/password_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
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
  final walletType;

  CreatePasswordScreen({this.showStep = true, this.showDoneScreen = true, this.isRecovery = false, this.mnemonic = const [], this.walletType = AccountCubit.localWalletType});

  @override
  _CreatePasswordScreenState createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  late TextEditingController _password;
  late TextEditingController _confirmPass;
  final int passwordLength = 8;
  bool isEnabledCheckbox = true;
  bool isEnable = false;
  bool isConfirm = false;
  bool isVisiblePassword = true;
  bool isVisibleConfirmPassword = true;
  String password = '';
  String confirmPassword = '';
  String errorHint = 'Must be at least 8 characters';
  bool isFailed = false;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: AuthAppBar(
                  // isShowFullScreen: true,
                  ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: AuthAppBar(
                  isSmall: false,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        }),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) => Container(
        color: Theme.of(context).dialogBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        widget.showStep ? '4/4' : '',
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
                          passwordController: _password,
                          obscureText: isVisiblePassword,
                          hintText: 'Enter your Secret password',
                          onChanged: (value) {
                            password = value;
                            setState(() {});
                            validateButton();
                          },
                          onIconPressed: () => setState(() => isVisiblePassword = !isVisiblePassword),
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
                          passwordController: _confirmPass,
                          obscureText: isVisibleConfirmPassword,
                          hintText: 'Confirm password',
                          onChanged: (value) {
                            confirmPassword = value;
                            setState(() {});
                            validateButton();
                          },
                          onIconPressed: () => setState(() => isVisibleConfirmPassword = !isVisibleConfirmPassword),
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
                                onChanged: isEnabledCheckbox
                                    ? (newValue) {
                                        setState(
                                          () {
                                            isConfirm = newValue!;
                                            setState(() {});
                                            validateButton();
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
                                          text: 'I understand that this password cannot be recovered.',
                                          style: Theme.of(context).textTheme.subtitle1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: isEnabledCheckbox
                                      ? () {
                                          setState(
                                            () {
                                              isConfirm = !isConfirm;
                                              validateButton();
                                            },
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 26),
                      StretchBox(
                        child: BlocBuilder<AccountCubit, AccountState>(
                          builder: (context, state) {
                            return PendingButton(
                              'Create password',
                              pendingText: state.status == AccountStatusList.restore ? 'Pending... (${state.restored}/${state.needRestore})' : 'Pending...',
                              isCheckLock: false,
                              callback: isEnable
                                  ? (parent) {
                                      _loadWallet(parent);
                                    }
                                  : null,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _loadWallet(parent) async {
    if (password == confirmPassword && password.length >= passwordLength) {
      setState(() {
        isEnabledCheckbox = false;
        isFailed = false;
      });
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
      var box = await Hive.openBox(HiveBoxes.client);
      box.put(HiveNames.password, stringToBase64.encode(password));

      parent.emitPending(true);

      Future.delayed(const Duration(milliseconds: 500), () async {
        if (widget.isRecovery) {
          try {
            if (this.widget.walletType == AccountCubit.ledgerWalletType) {
              await accountCubit.restoreLedgerAccount(password);
            } else {
              await accountCubit.restoreAccount(widget.mnemonic, password);
            }
            LoggerService.invokeInfoLogg('user was recover wallet');
          } catch (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Something error',
                  style: Theme.of(context).textTheme.headline5,
                ),
                backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
              ),
            );
          }
        } else {
          if (this.widget.walletType == AccountCubit.ledgerWalletType) {
            await accountCubit.createLedgerAccount();
          } else {
            if (widget.mnemonic.length != 0) {
              await accountCubit.createAccount(widget.mnemonic, password);
              LoggerService.invokeInfoLogg('user created new wallet');
            }
          }
        }

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                widget.showDoneScreen
                    ? SecureDoneScreen()
                    : HomeScreen(
                        isLoadTokens: true,
                      ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
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

  @override
  void initState() {
    super.initState();
    _confirmPass = TextEditingController();
    _password = TextEditingController();

    _password.text = "google123A";
    _confirmPass.text = "google123A";

    password = "google123A";
    confirmPassword = "google123A";
  }

  @override
  void dispose() {
    _confirmPass.dispose();
    _password.dispose();
    super.dispose();
  }

  void validateButton() {
    bool isValid = true;

    isValid = _password.text.isNotEmpty && _confirmPass.text.isNotEmpty && isConfirm;

    setState(() {
      isEnable = isValid;
    });
  }
}
