import 'dart:convert';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/requests/token_requests.dart';
import 'package:http/http.dart' as http;

class DexRequests {
  var tokenRequests = TokenRequests();
  var networkHelper = NetworkHelper();

  Future<List<double>?> getDexRate(
      String tokenFrom, String tokenTo, TokensState tokensState) async {
    var tokenFromId =
        await tokenRequests.getTokenID(tokenFrom, tokensState.tokens!);
    var tokenToId =
        await tokenRequests.getTokenID(tokenTo, tokensState.tokens!);
    try {
      double priceFromTo = 1;
      double priceToFrom = 1;
      tokensState.tokensPairs!.forEach((element) {
        if (element.idA == tokenFromId && element.idB == tokenToId) {
          priceFromTo = element.reserveA! / element.reserveB!;
          priceToFrom = element.reserveB! / element.reserveA!;
        } else if (element.idB == tokenFromId && element.idA == tokenToId) {
          priceFromTo = element.reserveB! / element.reserveA!;
          priceToFrom = element.reserveA! / element.reserveB!;
        }
      });

      return [
        double.parse((priceFromTo).toStringAsFixed(8)),
        double.parse((priceToFrom).toStringAsFixed(8))
      ];
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> getPoolPairs({String json = ''}) async {
    try {
      late final response;
      if (json == '') {
        String hostUrl = SettingsHelper.getHostApiUrl();
        String urlAddress =
            '$hostUrl/${networkHelper.getNetworkString()}/poolpairs?size=200';
        final Uri url = Uri.parse(urlAddress);

        response = await http.get(url);
      }

      var pairs = {};
      var dexHash;
      List<AssetPairModel> assetPairs = [];
      if (json == '') {
        if (response.statusCode == 200) {
          dexHash = jsonDecode(response.body)["data"];
        } else {
          return null;
        }
      } else {
        dexHash = jsonDecode(json);
      }
      dexHash.forEach((el) {
        var assetPair = AssetPairModel.fromJson(el);
        assetPairs.add(assetPair);
      });

      dexHash.forEach((value) {
        var arr = value['symbol'].split('-');
        if (pairs[arr[0]] == null) {
          pairs[arr[0]] = [arr[1]];
        } else {
          if (!pairs[arr[0]].contains(arr[1])) {
            pairs[arr[0]].add(arr[1]);
          }
        }

        if (pairs[arr[1]] == null) {
          pairs[arr[1]] = [arr[0]];
        } else {
          if (!pairs[arr[1]].contains(arr[0])) {
            pairs[arr[1]].add(arr[0]);
          }
        }
      });
      return [pairs, assetPairs];
    } catch (_) {
      return null;
    }
  }
}
