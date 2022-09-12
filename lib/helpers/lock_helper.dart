import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/router_helper.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/utils/routes.dart';
import 'package:defi_wallet/utils/theme_checker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LockHelper {
  RouterHelper routerHelper = RouterHelper();

  Future<void> provideWithLockChecker(context, Function() callback) async {
    var box = await Hive.openBox(HiveBoxes.client);
    var openTime = await box.get(HiveNames.openTime);
    await box.close();

    if (openTime != null &&
        openTime + TickerTimes.tickerBeforeLockMilliseconds <
            DateTime.now().millisecondsSinceEpoch) {
      await routerHelper.setCurrentRoute(Routes.home);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2)  => ThemeChecker(LockScreen()),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      await updateTimer();
      callback();
    }
  }

  Future<void> lockWallet() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.openTime, 0);
    await box.close();
  }

  Future<void> updateTimer() async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);
      await box.put(HiveNames.openTime, DateTime.now().millisecondsSinceEpoch);
      await box.close();
    } catch (err) {
      print(err);
    }
  }
}