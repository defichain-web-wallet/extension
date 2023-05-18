import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:http/http.dart' as http;

class DFITokenRequests {
  static Future<List<TokenModel>> getTokens({
    String? next,
    required NetworkTypeModel networkType,
  }) async {
    Map<String, dynamic> query = {
      'size': '200',
    };

    if (next != null) {
      query['next'] = next;
    }

    try {
      //TODO: add fallback url
      final Uri url = Uri.https(
        Hosts.oceanDefichainHome,
        '/v0/${networkType.networkStringLowerCase}/tokens',
        query,
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic json = jsonDecode(response.body);
        List<TokenModel> tokens =
            TokenModel.fromJSONList(json['data'], networkType.networkName);

        if (json['page'] != null) {
          var nextTokenList = await getTokens(
            next: json['page']['next'],
            networkType: networkType,
          );
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
