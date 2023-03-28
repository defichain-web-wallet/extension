import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

import '../../models/settings_model.dart';

enum BalanceFilter {ALL, LPPool, Tokens}

class DFIBalanceRequests {
  static Future<List<TokenModel>> getBalanceList(
      {required NetworkTypeModel networkType,required String addressString}) async {
    //TODO: add fallback URL
    String urlAddress =
        'https://ocean.defichain.com/${networkType.networkStringLowerCase}address/$addressString/tokens';
    final Uri url = Uri.parse(urlAddress);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var tokens = TokenModel.fromJSONList(json, networkType.networkName);

        return tokens;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }
}
