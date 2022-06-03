import 'dart:convert';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:http/http.dart' as http;

class TokenRequests {
  var networkHelper = NetworkHelper();
  var tokenHelper = TokensHelper();

  Future<List<dynamic>> getTokensResponse() async {
    final Uri url = Uri.parse(
        'https://ocean.defichain.com/v0/${networkHelper.getNetworkString()}/tokens?size=200');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return new List.from(json['data']);
    } else {
      return [];
    }
  }

  Future<List<TokensModel>> getTokenList({String json = ''}) async {
    try {
      List<dynamic> tokensHash;
      List<TokensModel> tokens = [];
      if (json == '') {
        tokensHash = await getTokensResponse();
      } else {
        tokensHash = jsonDecode(json);
      }

      tokensHash.forEach((el) {
        var token = TokensModel.fromJson(el);
        if (token.isDAT!) {
          tokens.add(token);
        }
      });
      return tokens;
    } catch (err) {
      return [];
    }
  }

  Future<int?> getTokenID(String token, List<TokensModel> tokens) async {
    int? tokenId;
    tokens.forEach((element) {
      if (element.symbol == token) {
        tokenId = element.id;
      }
    });
    return tokenId;
  }

  Future<double> getEurByUsdRate() async {
    final Uri url = Uri.parse('https://api.exchangerate.host/latest?base=USD');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      return res['rates']['EUR'];
    } else {
      return 1.0;
    }
  }
}
