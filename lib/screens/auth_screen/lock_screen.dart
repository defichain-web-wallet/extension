import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
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
  final Widget? redirectTo;

  const LockScreen({Key? key, this.redirectTo}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  SettingsHelper settingsHelper = SettingsHelper();
  bool isEnable = true;
  bool isVisiblePasswordField = true;
  String password = '';
  bool isFailed = false;
  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: WelcomeAppBar(),
        body: Container(
          color: Theme.of(context).dialogBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/jelly_logo.svg',
                    height: 180,
                    width: 200,
                  ),
                  Text(
                    widget.redirectTo == null
                        ? 'Welcome Back!'
                        : 'Enter password',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your Keys. Your Crypto.',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  SizedBox(height: 25),
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
                      widget.redirectTo == null ? 'Unlock' : 'Continue',
                      isCheckLock: false,
                      globalKey: globalKey,
                      callback: (parent) => _restoreWallet(parent),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (widget.redirectTo == null)
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
          ),
        ),
      );

  void _restoreWallet(parent) async {
    setState(() {
      isFailed = false;
      isEnable = false;
    });
    var box = await Hive.openBox(HiveBoxes.client);
    var decodedPassword = stringToBase64.decode(box.get(HiveNames.password));
    if (password == decodedPassword) {
      parent.emitPending(true);
      if (widget.redirectTo == null) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
        FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

        await accountCubit
            .restoreAccountFromStorage(SettingsHelper.settings.network!);
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
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                widget.redirectTo!,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    } else {
      setState(() {
        isFailed = true;
        isEnable = true;
      });
    }
  }
}
