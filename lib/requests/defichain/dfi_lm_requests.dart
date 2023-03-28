import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

import '../../models/settings_model.dart';

class DFILmRequests {
  static Future<List<LmPoolModel>> getLmPools(
      {String? next, required NetworkTypeModel networkType}) async {
    //TODO: add fallback url
    String urlAddress =
        'https://ocean.defichain.com/v0/${networkType.networkStringLowerCase}/poolpairs?size=200${next != null ? '&next=$next' : ''}';
    final Uri url = Uri.parse(urlAddress);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var tokens = LmPoolModel.fromJSONList(json, networkType.networkName);
        if (json['page'] != null) {
          var nextTokenList = await getLmPools(
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
