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

class DFITokenRequests {
  static Future<List<TokenModel>> getTokens(
      {String? next, required NetworkTypeModel networkType}) async {
    //TODO: add fallback URL
    String urlAddress =
        'https://ocean.defichain.com/${networkType.networkStringLowerCase}/tokens?size=200${next != null ? '&next=$next' : ''}';
    final Uri url = Uri.parse(urlAddress);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var tokens = TokenModel.fromJSONList(json, networkType.networkName);

        if (json['page'] != null) {
          var nextTokenList = await getTokens(
              next: json['page']['next'], networkType: networkType);
          tokens.addAll(nextTokenList);
        }

        return tokens;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }
}
