import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/auth_screen/auth_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/secure_wallet_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/create_password_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/theme_checker.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/screens/auth_screen/recovery/recovery_screen.dart';

class WalletChecker extends StatefulWidget {
  @override
  State<WalletChecker> createState() => _WalletCheckerState();
}

class _WalletCheckerState extends State<WalletChecker> {
  SettingsHelper settingsHelper = SettingsHelper();
  LockHelper lockHelper = LockHelper();
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  @override
  Widget build(BuildContext context) {
    Future<void> checkWallets() async {
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      var box = await Hive.openBox(HiveBoxes.client);
      var masterKeyPairName;
      if (SettingsHelper.settings.network! == 'testnet') {
        masterKeyPairName = HiveNames.masterKeyPairTestnet;
      } else {
        masterKeyPairName = HiveNames.masterKeyPairMainnet;
      }
      var masterKeyPair = await box.get(masterKeyPairName);
      var password = await box.get(HiveNames.password);
      bool isSavedMnemonic = await box.get(HiveNames.openedMnemonic) != null;
      String? savedMnemonic = await box.get(HiveNames.openedMnemonic);

      bool isRecoveryMnemonic =
          await box.get(HiveNames.recoveryMnemonic) != null;
      String? recoveryMnemonic = await box.get(HiveNames.recoveryMnemonic);

      if (password != null) {
        password = stringToBase64.decode(password);
      }
      await settingsHelper.loadSettings();
      await box.close();

      if (masterKeyPair != null) {
        if (password != null) {
          lockHelper.provideWithLockChecker(context, () async {
            await accountCubit
                .restoreAccountFromStorage(SettingsHelper.settings.network!);
            await Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(HomeScreen(
                  isLoadTokens: true,
                )),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          });
        } else {
          await accountCubit
              .restoreAccountFromStorage(SettingsHelper.settings.network!);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ThemeChecker(
                  CreatePasswordScreen(showStep: false, showDoneScreen: false)),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        if (isSavedMnemonic) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  ThemeChecker(SecureScreen(mnemonic: savedMnemonic)),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          if (isRecoveryMnemonic) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(RecoveryScreen(
                  mnemonic: recoveryMnemonic,
                )),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(AuthScreen()),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      }
    }

    checkWallets();

    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Center(child: Loader()),
    );
  }
}
