import 'dart:convert';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/requests/token_requests.dart';
import 'package:http/http.dart' as http;

class DexRequests {
  var tokenRequests = TokenRequests();
  var networkHelper = NetworkHelper();

  Future<List<double>?> getDexRate(String tokenFrom, String tokenTo, List<TokensModel> tokens) async {
    var tokenFromId = await tokenRequests.getTokenID(tokenFrom, tokens);
    var tokenToId = await tokenRequests.getTokenID(tokenTo, tokens);
    try {
      final Uri url = Uri.parse(
        'https://ocean.defichain.com/v0/${networkHelper.getNetworkString()}/poolpairs');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var dexHash = jsonDecode(response.body);
        double priceFromTo = 1;
        double priceToFrom = 1;
        dexHash['data'].forEach((value) {
          if(value['tokenA']['id'] == tokenFromId.toString() && value['tokenB']['id'] == tokenToId.toString()){
            priceFromTo = double.parse(value['tokenA']['reserve']) / double.parse(value['tokenB']['reserve']);
            priceToFrom = double.parse(value['tokenB']['reserve']) / double.parse(value['tokenA']['reserve']);
          } else if(value['tokenB']['id'] == tokenFromId.toString() && value['tokenA']['id'] == tokenToId.toString()){
            priceFromTo = double.parse(value['tokenB']['reserve']) / double.parse(value['tokenA']['reserve']);
            priceToFrom = double.parse(value['tokenA']['reserve']) / double.parse(value['tokenB']['reserve']);
          }
        });

        return [double.parse((priceFromTo).toStringAsFixed(8)), double.parse((priceToFrom).toStringAsFixed(8))];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  Future<dynamic> getPoolPairs() async {
    try {
      final Uri url = Uri.parse(
          'https://ocean.defichain.com/v0/${networkHelper.getNetworkString()}/poolpairs');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var pairs = {};
        List<AssetPairModel> assetPairs = [];
        var dexHash = jsonDecode(response.body);
        dexHash['data'].forEach((el) {
          var assetPair = AssetPairModel.fromJson(el);
          assetPairs.add(assetPair);
        });

        dexHash['data'].forEach((value) {
          var arr = value['symbol'].split('-');
          if(pairs[arr[0]] == null) {
            pairs[arr[0]] = [arr[1]];
          } else{
            if(!pairs[arr[0]].contains(arr[1])){
              pairs[arr[0]].add(arr[1]);
            }
          }

          if(pairs[arr[1]] == null) {
            pairs[arr[1]] = [arr[0]];
          } else{
            if(!pairs[arr[1]].contains(arr[0])){
              pairs[arr[1]].add(arr[0]);
            }
          }
        });
        return [pairs, assetPairs];
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
