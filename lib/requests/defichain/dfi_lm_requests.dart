import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:http/http.dart' as http;

class DFILmRequests {
  static Future<List<LmPoolModel>> getLmPools({
    String? next,
    required NetworkTypeModel networkType,
    required List<TokenModel> tokens
  }) async {
    final query = {
      'size': '200',
    };

    if (next != null) {
      query['next'] = next;
    }

    final Uri url = Uri.https(
      networkType.isTestnet ? Hosts.testnetHost : Hosts.mainnetHost,
      '/v0/${networkType.networkStringLowerCase}/poolpairs',
      query,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic json = jsonDecode(response.body);
        List<dynamic> data = json['data'];
        List<dynamic> elements = [];
        data.forEach((element) {
          if(element['tradeEnabled'] && element['symbol'].indexOf('BURN') < 0){
            elements.add(element);
          }
        });
        List<LmPoolModel> lmTokens = LmPoolModel.fromJSONList(
          elements,
          networkType.networkName,
          tokens,
        );
        if (json['page'] != null) {
          var nextTokenList = await getLmPools(
            next: json['page']['next'],
            networkType: networkType,
              tokens: tokens
          );
          lmTokens.addAll(nextTokenList);
        }

        return lmTokens;
      } else {
        return [];
      }
    } catch (err) {
      throw err;
    }
  }
}
