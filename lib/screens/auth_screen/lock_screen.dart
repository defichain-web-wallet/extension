import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/auth_screen/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/password_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/services/logger_service.dart';

class LockScreen extends StatefulWidget {
  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  SettingsHelper settingsHelper = SettingsHelper();
  bool isVisiblePasswordField = true;
  String password = '';
  bool isFailed = false;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: WelcomeAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/jelly_logo.svg',
                  height: 220,
                  width: 220,
                ),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 20),
                Text(
                  'Your Keys. Your Crypto.',
                  style: Theme.of(context).textTheme.headline2,
                ),
                SizedBox(height: 30),
                StretchBox(
                  maxWidth: ScreenSizes.xSmall,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                      SizedBox(height: 8),
                      PasswordField(
                        autofocus: true,
                        obscureText: isVisiblePasswordField,
                        onEditComplete: () =>
                            (globalKey.currentWidget! as ElevatedButton)
                                .onPressed!(),
                        hintText: 'Enter password',
                        onChanged: (value) => password = value,
                        onIconPressed: () => setState(() =>
                        isVisiblePasswordField = !isVisiblePasswordField),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isFailed ? 'Incorrect password' : '',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                          color: AppTheme.redErrorColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                StretchBox(
                  maxWidth: ScreenSizes.xSmall,
                  child: PendingButton(
                    'Unlock',
                    isCheckLock: false,
                    globalKey: globalKey,
                    callback: (parent) => _restoreWallet(parent),
                  ),
                ),
                SizedBox(height: 24),
                InkWell(
                  child: Text(
                    'or import using Secret Recovery Phrase',
                    style: AppTheme.defiUnderlineText,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecoveryScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _restoreWallet(parent) async {
    setState(() {
      isFailed = false;
    });
    var box = await Hive.openBox(HiveBoxes.client);
    var decodedPassword =
    stringToBase64.decode(box.get(HiveNames.password));
    if (password == decodedPassword) {
      parent.emitPending(true);

      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

      await accountCubit
          .restoreAccountFromStorage(SettingsHelper.settings.network);
      LoggerService.invokeInfoLogg('user was unlock wallet');
      Future.delayed(const Duration(milliseconds: 300), () async {
        parent.emitPending(false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(isLoadTokens: true),
          ),
        );
      });
    } else {
      setState(() {
        isFailed = true;
      });
    }
  }
}
