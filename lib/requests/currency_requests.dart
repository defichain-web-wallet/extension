import 'package:defi_wallet/helpers/network_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyRequests {
  var networkHelper = NetworkHelper();

  static var fiatMap = {};

  Future<Map<String,double>> getCoingeckoList(String currency) async {
    try {
      final Uri url = Uri.parse(
          'https://supernode.saiive.live/api/v1/${networkHelper.getNetworkString()}/DFI/coin-price/$currency');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String,double> coins = {};
        var data = jsonDecode(response.body);
        data.forEach((k, v){
          var key;
          switch (k) {
            case 'tether': key = 'USDT'; break;
            case 'litecoin': key = 'LTC'; break;
            case 'bitcoin': key = 'BTC'; break;
            case 'ethereum': key = 'ETH'; break;
            case 'dogecoin': key = 'DODGE'; break;
            case 'defichain': key = 'DFI'; break;
          }
          coins[key] = v['fiat'];
        });
        fiatMap[currency] = coins;
        return coins;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  bool isFiat(String coin, String currency) {
    return fiatMap.containsKey(currency) & fiatMap[currency].containsKey(coin);
  }

  double? getFiat(String coin, String currency, double balance) {
    if (isFiat(coin, currency)) return fiatMap[currency][coin] * balance;
    return null;
  }
}