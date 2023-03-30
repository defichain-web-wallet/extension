import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_lm_provider_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

import '../../models/settings_model.dart';

class DFIExchangeRequests {
  static Future<List<ExchangePairModel>> getExchangePairs(
      {String? next, required NetworkTypeModel networkType}) async {
    //TODO: add fallback url
    String urlAddress =
        'https://ocean.defichain.com/v0/${networkType.networkStringLowerCase}/poolpairs?size=200${next != null ? '&next=$next' : ''}';
    final Uri url = Uri.parse(urlAddress);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var pairs = ExchangePairModel.fromJSONList(json, networkType.networkName);
        if (json['page'] != null) {
          var nextTokenList = await getExchangePairs(
              next: json['page']['next'], networkType: networkType);
          pairs.addAll(nextTokenList);
        }

        return pairs;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }
}
