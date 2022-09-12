import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/forms/kyc_name_former.dart';
import 'package:defi_wallet/models/forms/send_former.dart';
import 'package:defi_wallet/models/forms/swap_former.dart';
import 'package:defi_wallet/screens/buy/contact_screen.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/screens/earn_screen/earn_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_screen.dart';
import 'package:defi_wallet/screens/receive/receive_screen.dart';
import 'package:defi_wallet/screens/select_buy_or_sell/select_buy_or_sell_screen.dart';
import 'package:defi_wallet/screens/sell/account_type_sell.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/screens/send/send_token_selector.dart';
import 'package:defi_wallet/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RouterHelper {
  redirectTo(context) async {
    var box = await Hive.openBox(HiveBoxes.client);
    String? currentRoute = await box.get(HiveNames.currentRoute);
    String? form = await box.get(HiveNames.sendState);
    await box.close();

    if (currentRoute != null && currentRoute != Routes.home.toShortString()) {
      Widget target = await getWidgetByRoute(currentRoute, form);

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => target,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  setCurrentRoute(Routes routeName) async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.currentRoute, routeName.toShortString());
    await box.put(HiveNames.sendState, null);
    await box.close();
  }

  getWidgetByRoute(String currentRoute, String? form) async {
    switch (currentRoute) {
      case 'send':
        {
          SendFormer? sendFormer;
          if (form != null) {
            sendFormer = SendFormer.fromJson(jsonDecode(form));
          }
          return SendTokenSelector(
            former: sendFormer,
            isSaveRoute: false,
          );
        }
      case 'receive':
        return ReceiveScreen();
      case 'swap':
        {
          SwapFormer? swapFormer;
          if (form != null) {
            swapFormer = SwapFormer.fromJson(jsonDecode(form));
          }
          return SwapScreen(former: swapFormer);
        }
      case 'buySell':
        return SelectBuyOrSellScreen();
      case 'earn':
        return EarnScreen();
      case 'buy':
        return SearchBuyToken();
      case 'sell':
        return Selling();
      case 'kycName':
        {
          KycNameFormer? former;
          if (form != null) {
            former = KycNameFormer.fromJson(jsonDecode(form));
          }
          return AccountTypeSell(
            former: former,
            isSaveRoute: false,
          );
        }
      case 'kycContactBuy':
        return ContactScreen();
      default:
        {
          await setCurrentRoute(Routes.home);
          return HomeScreen(
            isLoadTokens: true,
          );
        }
    }
  }
}
