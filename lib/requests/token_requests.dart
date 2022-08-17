import 'dart:convert';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:http/http.dart' as http;

class TokenRequests {
  var networkHelper = NetworkHelper();
  var tokenHelper = TokensHelper();

  Future<List<dynamic>> getTokensResponse() async {
    String hostUrl = SettingsHelper.getHostApiUrl();
    String urlAddress =
        '$hostUrl/${SettingsHelper.settings.network}/tokens?size=200';
    final Uri url = Uri.parse(urlAddress);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return List.from(json['data']);
      } else {
        return [];
      }
    } catch (err) {
      throw err;
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

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        return res['rates']['EUR'];
      } else {
        return 1.0;
      }
    } catch (_) {
      return 1.0;
    }
  }
}
