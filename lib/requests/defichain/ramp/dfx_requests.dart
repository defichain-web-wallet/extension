import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/fiat_history_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/network/ramp/ramp_user_model.dart';
import 'package:defi_wallet/models/network/staking/staking_model.dart';
import 'package:http/http.dart' as http;

class DFXRequests {
  static Future<String> signUp(Map<String, String> data) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/auth/signUp');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  static Future<String> signIn(Map<String, String> data) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/auth/signIn');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  static Future<void> createUser(
    String email,
    String phone,
    String accessToken,
  ) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/user');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode({
        'mail': email,
        'phone': phone,
      });

      await http.put(url, headers: headers, body: body);
    } catch (error) {
      throw error;
    }
  }

  // TODO: move return value to global variable of this object
  static Future<CryptoRouteModel?> getCryptoRoutes(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/cryptoRoute');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.length == 0) {
          return null;
        }
        return CryptoRouteModel.fromJson(data[0]);
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (error) {
      throw error;
    }
  }

  static Future<CryptoRouteModel> createCryptoRoute(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/cryptoRoute');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode({
        "type": "Wallet",
        "blockchain": "Bitcoin",
        "asset": {"id": 2}
      });
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        return CryptoRouteModel.fromJson(data);
      } else {
        throw Error.safeToString(jsonDecode(response.body)['message']);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<bool> transferKYC(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/kyc/transfer');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode({"walletName": "LOCK.space"});

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<RampUserModel> getUserDetails(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/user');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return RampUserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<List<FiatHistoryModel>> getHistory(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/history');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<FiatHistoryModel> history = List.generate(
          data.length,
          (index) => FiatHistoryModel.fromJson(data[index]),
        );
        return history;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<List<AssetByFiatModel>> getAvailableAssets(
    String accessToken,
  ) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/asset');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<AssetByFiatModel> assets = List.generate(
          data.length,
          (index) => AssetByFiatModel.fromJson(data[index]),
        );
        return assets;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<List<IbanModel>> getIbanList(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/route');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> dataBuy = jsonDecode(response.body)["buy"];
        List<dynamic> dataSell = jsonDecode(response.body)["sell"];
        List<IbanModel> buyIbanList = List.generate(
          dataBuy.length,
          (index) => IbanModel.fromJson(dataBuy[index]),
        );
        List<IbanModel> sellIbanList = List.generate(
          dataSell.length,
          (index) => IbanModel.fromJson(dataSell[index]),
        );
        buyIbanList.addAll(sellIbanList);
        return buyIbanList;
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  static Future<List<dynamic>> getCountryList(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/route');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<void> saveKycData(KycModel kyc, String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/kyc/data');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode(kyc.toJson());

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Error.safeToString(jsonDecode(response.body)['message']);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<List<FiatModel>> getFiatList(String accessToken) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/fiat');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = jsonDecode(response.body);
        List<FiatModel> fiatList = List.generate(
          data.length,
          (index) => FiatModel.fromJson(data[index]),
        );
        return fiatList;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<void> buy(
    String iban,
    AssetByFiatModel asset,
    String accessToken,
  ) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/buy');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode({
        'type': "Wallet",
        'iban': iban,
        'asset': asset.toJson(),
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        var errorMessage = jsonDecode(response.body);
        throw Error.safeToString(errorMessage['message'] is List
            ? errorMessage['message'][0]
            : errorMessage['message']);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<Map> sell(
    String iban,
    FiatModel fiat,
    String accessToken,
  ) async {
    try {
      final Uri url = Uri.https(DfxApi.home, '/v1/sell');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final body = jsonEncode({
        'iban': iban,
        'fiat': fiat.toJson(),
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        var errorMessage = jsonDecode(response.body);
        throw Error.safeToString(errorMessage['message'] is List
            ? errorMessage['message'][0]
            : errorMessage['message']);
      }
    } catch (err) {
      throw err;
    }
  }
}
