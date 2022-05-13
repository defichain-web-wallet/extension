import 'dart:convert';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:http/http.dart' as http;

class TokenRequests {
  var networkHelper = NetworkHelper();
  var tokenHelper = TokensHelper();

  Future<List<dynamic>> getTokensResponse(list, {next = 0}) async {
    final Uri url = Uri.parse(
        'https://ocean.defichain.com/v0/${networkHelper.getNetworkString()}/tokens${(next == 0) ? '' : '?next=$next'}');

    final response = await http.get(url);
    List<dynamic> result = list;
    var pageNext = next;

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['page'] != null) {
        pageNext = json['page']['next'];
        result = new List.from(result)..addAll(json['data']);
        return await getTokensResponse(result, next: pageNext);
      }
      return result;
    } else {
      return [];
    }
  }

  Future<List<TokensModel>> getTokenList() async {
    try {
      List<dynamic> tokensHash = await getTokensResponse([], next: 0);

      List<TokensModel> tokens = [];

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
