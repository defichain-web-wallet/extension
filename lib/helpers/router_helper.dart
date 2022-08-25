import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/forms/send_former.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screen.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/select_buy_or_sell_screen.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/screens/send/send_token_selector.dart';
import 'package:defi_wallet/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RouterHelper {
  redirectTo(context) async {
    var box = await Hive.openBox(HiveBoxes.state);
    String? currentRoute = await box.get(HiveNames.currentRoute);
    String? form = await box.get(HiveNames.sendState);
    await box.close();

    if (currentRoute != null && currentRoute != Routes.home.toShortString()) {
      Widget target = await getWidgetByRoute(currentRoute, form);

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
          target,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  setCurrentRoute(Routes routeName) async {
    var box = await Hive.openBox(HiveBoxes.state);
    await box.put(HiveNames.currentRoute, routeName.toShortString());
    await box.put(HiveNames.sendState, null);
    await box.close();
  }

  getWidgetByRoute(String currentRoute, String? form) async {
    switch (currentRoute) {
      case 'send': {
        SendFormer? sendFormer;
        if (form != null) {
          sendFormer = SendFormer.fromJson(jsonDecode(form));
        } else {
          sendFormer = SendFormer.init();
        }
        return SendTokenSelector(former: sendFormer);
      }
      case 'receive':
        return ReceiveScreen();
      case 'swap':
        return SwapScreen();
      case 'buySell':
        return SelectBuyOrSellScreen();
      case 'earn':
        return LiquidityScreen();
      case 'buy':
        return SearchBuyToken();
      case 'sell':
        return Selling();
      default: {
        await setCurrentRoute(Routes.home);
        return HomeScreen(
          isLoadTokens: true,
        );
      }
    }
  }
}