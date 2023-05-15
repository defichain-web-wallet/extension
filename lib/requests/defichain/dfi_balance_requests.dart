import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:http/http.dart' as https;

class DFIBalanceRequests {
  static Future<List<BalanceModel>> getBalanceList({
    required AbstractNetworkModel network,
    required String addressString,
    required List<TokenModel> tokens,
  }) async {
    //TODO: add fallback URL
    String urlAddress =
        '${Hosts.oceanDefichain}/${network.networkType.networkStringLowerCase}'
        '/address/$addressString/tokens';
    final Uri url = Uri.parse(urlAddress);
    try {
      final response = await https.get(url);

      if (response.statusCode == 200) {
        List<dynamic> json = jsonDecode(response.body)['data'];
        List<BalanceModel> balances = BalanceModel.fromJSONList(
          json,
          network,
          tokens
        );
        BalanceModel utxoBalance = await DFIBalanceRequests.getUTXOBalance(
          network: network,
          addressString: addressString,
        );
        balances.add(utxoBalance);
        return balances;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<BalanceModel> getUTXOBalance({
    required AbstractNetworkModel network,
    required String addressString,
  }) async {
    try {
      BalanceModel balance = BalanceModel(
        token: network.getDefaultToken(),
        balance: 0,
      );

      String urlAddress =
          '${Hosts.oceanDefichain}/${network.networkType.networkStringLowerCase}'
          '/address/$addressString/balance';
      final Uri url = Uri.parse(urlAddress);

      final response = await https.get(url);

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        balance.balance = network.toSatoshi(double.parse(data['data']));
      }
      //TODO: need to check error
      return balance;
    } catch (err) {
      throw err;
    }
  }
}
