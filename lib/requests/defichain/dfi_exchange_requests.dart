import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:http/http.dart' as http;

class DFIExchangeRequests {
  static Future<List<ExchangePairModel>> getExchangePairs({
    String? next,
    required NetworkTypeModel networkType,
  }) async {
    final query = {
      'size': 200,
      'next': next ?? '',
    };

    //TODO: add fallback url
    final Uri url = Uri.https(
      Hosts.oceanDefichainHome,
      '/v0/${networkType.networkStringLowerCase}/poolpairs',
      query,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic json = jsonDecode(response.body);
        List<ExchangePairModel> pairs =
            ExchangePairModel.fromJSONList(json, networkType.networkName);
        if (json['page'] != null) {
          var nextTokenList = await getExchangePairs(
            next: json['page']['next'],
            networkType: networkType,
          );
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
