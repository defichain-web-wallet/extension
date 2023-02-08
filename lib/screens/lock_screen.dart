import 'dart:convert';
import 'package:crypt/crypt.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/welcome_positioned_logo.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/password_field.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/services/logger_service.dart';

class LockScreen extends StatefulWidget {
  final callback;

  const LockScreen({Key? key, this.callback}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  SettingsHelper settingsHelper = SettingsHelper();
  bool isPasswordObscure = true;
  bool isEnable = true;
  bool isValid = true;
  bool isVisiblePasswordField = true;
  String password = '';
  bool isFailed = false;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  GlobalKey globalKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();

  PasswordStatusList passwordStatus = PasswordStatusList.initial;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: const EdgeInsets.only(bottom: 42),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: WelcomePositionedLogo(
                        imgWidth: 250,
                        titleSpace: 345,
                        title: 'Welcome back',
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    padding: authPaddingContainer.copyWith(
                      top: 0,
                      bottom: 0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          PasswordTextField(
                            height: 71,
                            controller: _passwordController,
                            status: passwordStatus,
                            hint: 'Your password',
                            label: 'Password',
                            isShowObscureIcon: true,
                            isCaptionShown: false,
                            onEditComplete: () =>
                                (globalKey.currentWidget! as ElevatedButton)
                                    .onPressed!(),
                            isObscure: isPasswordObscure,
                            onChanged: (String value) {
                              password = value;
                            },
                            onPressObscure: () {
                              setState(
                                      () => isPasswordObscure = !isPasswordObscure);
                            },
                            validator: (val){
                              return isValid ? null : "Incorrect password";
                            },
                          ),
                          // SizedBox(height: 24),
                          StretchBox(
                            maxWidth: ScreenSizes.xSmall,
                            child: PendingButton(
                              widget.callback == null ? 'Unlock' : 'Continue',
                              pendingText: 'Pending...',
                              isCheckLock: false,
                              globalKey: globalKey,
                              callback: (parent) => _restoreWallet(parent),
                            ),
                          ),
                          SizedBox(height: 20),
                          if (widget.callback == null)
                            InkWell(
                              child: Text(
                                'Forgot password?',
                                style: AppTheme.defiUnderlineText,
                              ),
                              onTap: isEnable
                                  ? () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                      RecoveryScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );

  void _restoreWallet(parent) async {
    setState(() {
      isValid = true;
      _formKey.currentState!.validate();
      isFailed = false;
      isEnable = false;
    });
    var box = await Hive.openBox(HiveBoxes.client);
    var encodedPassword = box.get(HiveNames.password);

    if (Crypt(encodedPassword).match(password)) {
      setState(() {
        isValid = true;
        _formKey.currentState!.validate();
      });
      parent.emitPending(true);
      if (widget.callback == null) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);

        await accountCubit.restoreAccountFromStorage(
          SettingsHelper.settings.network!,
          password: password,
        );
        if (SettingsHelper.isBitcoin()) {
          await bitcoinCubit
              .loadDetails(accountCubit.state.activeAccount!.bitcoinAddress!);
        }
        LoggerService.invokeInfoLogg('user was unlock wallet');
        parent.emitPending(false);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HomeScreen(isLoadTokens: true),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        widget.callback(password);
      }
    } else {
      setState(() {
        isValid = false;
        _formKey.currentState!.validate();
        passwordStatus = PasswordStatusList.error;
        isFailed = true;
        isEnable = true;
      });
    }
  }
}
