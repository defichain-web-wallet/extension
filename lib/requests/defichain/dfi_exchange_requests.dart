import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/token/exchange_pair_model.dart';
import 'package:http/http.dart' as http;

class DFIExchangeRequests {
  static Future<List<ExchangePairModel>> getExchangePairs({
    String? next,
    required AbstractNetworkModel network,
  }) async {
    final query = {
      'size': '200',
    };

    if (next != null) {
      query['next'] = next;
    }

    final Uri url = Uri.https(
      network.networkType.isTestnet ? Hosts.testnetHost : Hosts.mainnetHost,
      '/v0/${network.networkType.networkStringLowerCase}/poolpairs',
      query,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic json = jsonDecode(response.body);
        List<ExchangePairModel> pairs = ExchangePairModel.fromJSONList(
          json['data'],
          network.networkType.networkName,
        );
        if (json['page'] != null) {
          var nextTokenList = await getExchangePairs(
            next: json['page']['next'],
            network: network,
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
