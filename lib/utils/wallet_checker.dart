import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth/signup/signup_phrase_screen.dart';
import 'package:defi_wallet/screens/auth/welcome_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/services/storage/storage_service.dart';
import 'package:defi_wallet/utils/theme/theme_checker.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletChecker extends StatefulWidget {
  @override
  State<WalletChecker> createState() => _WalletCheckerState();
}

class _WalletCheckerState extends State<WalletChecker> {
  SettingsHelper settingsHelper = SettingsHelper();
  LockHelper lockHelper = LockHelper();

  @override
  Widget build(BuildContext context) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    ApplicationModel? applicationModel;

    Future<void> checkWallets() async {
      try {
        applicationModel = await StorageService.loadApplication();
      } catch (_) {
        applicationModel = null;
      }
      var box = await Hive.openBox(HiveBoxes.client);
      var savedMnemonic = await box.get(HiveNames.savedMnemonic);
      bool isOpenedMnemonic = await box.get(HiveNames.openedMnemonic) != null;
      String? openedMnemonic = await box.get(HiveNames.openedMnemonic);

      bool isRecoveryMnemonic =
          await box.get(HiveNames.recoveryMnemonic) != null;
      String? recoveryMnemonic = await box.get(HiveNames.recoveryMnemonic);

      bool isLedger =
          await box.get(HiveNames.ledgerWalletSetup, defaultValue: false);

      await settingsHelper.loadSettings();
      await box.close();

      if (savedMnemonic != null) {
        await lockHelper.lockWallet();

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ThemeChecker(
              LockScreen(
                savedMnemonic: savedMnemonic,
              ),
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      } else {
        if (applicationModel != null || isLedger) {
          lockHelper.provideWithLockChecker(context, () async {
            try {
              await walletCubit.loadWalletDetails(
                application: applicationModel,
              );
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
            } catch (err) {
              print(err);
            }
          });
        } else {
          if (isOpenedMnemonic) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(SignupPhraseScreen(mnemonic: openedMnemonic)),
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
                      ThemeChecker(WelcomeScreen()),
                  // ThemeChecker(UiKit()),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
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
