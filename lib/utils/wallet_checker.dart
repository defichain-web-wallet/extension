import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/requests/currency_requests.dart';
import 'package:defi_wallet/screens/auth_screen/auth_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/secure_wallet_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/create_password_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/theme_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class WalletChecker extends StatefulWidget {
  @override
  State<WalletChecker> createState() => _WalletCheckerState();
}

class _WalletCheckerState extends State<WalletChecker> {
  CurrencyRequests currencyRequests = CurrencyRequests();
  SettingsHelper settingsHelper = SettingsHelper();
  LockHelper lockHelper = LockHelper();
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  @override
  Widget build(BuildContext context) {
    Future<void> checkWallets() async {
      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      var box = await Hive.openBox(HiveBoxes.client);
      var masterKeyPairName;
      if(SettingsHelper.settings.network! == 'testnet'){
        masterKeyPairName = HiveNames.masterKeyPairTestnet;
      } else {
        masterKeyPairName = HiveNames.masterKeyPairMainnet;
      }
      var masterKeyPair = await box.get(masterKeyPairName);
      var password = await box.get(HiveNames.password);
      bool isSavedMnemonic = await box.get(HiveNames.openedMnemonic) != null;
      String savedMnemonic = await box.get(HiveNames.openedMnemonic);
      if (password != null) {
        password = stringToBase64.decode(password);
      }
      await settingsHelper.loadSettings();
      await box.close();
      await currencyRequests.getCoingeckoList('USD');
      await currencyRequests.getCoingeckoList('EUR');

      if (masterKeyPair != null) {
        if (password != null) {
          lockHelper.provideWithLockChecker(context, () async {
            await accountCubit.restoreAccountFromStorage(SettingsHelper.settings.network);
            Future.delayed(const Duration(milliseconds: 300), () async {
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ThemeChecker(HomeScreen(isLoadTokens: true,)),
                ),
              );
            });
          });
        } else {
          await accountCubit.restoreAccountFromStorage(SettingsHelper.settings.network);
          Future.delayed(const Duration(milliseconds: 300), () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ThemeChecker(
                  CreatePasswordScreen(
                    showStep: false,
                    showDoneScreen: false
                  )
                ),
              ),
            );
          });
        }
      } else {
        if (isSavedMnemonic) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThemeChecker(SecureScreen(mnemonic: savedMnemonic)),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ThemeChecker(AuthScreen()),
            ),
          );
        }
      }
    }

    checkWallets();

    return Container();
  }
}
