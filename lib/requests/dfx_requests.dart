import 'dart:convert';
import 'package:defi_wallet/bloc/staking/staking_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/staking_model.dart';
import 'package:defi_wallet/services/dfx_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class DfxRequests {
  DFXService dfxService = DFXService();
  EncryptHelper encryptHelper = EncryptHelper();

  Future<String> signUp(AccountModel account) async {
    try {
      dynamic data = dfxService.getAddressAndSignature(account);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/auth/signUp');

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

  Future<String> signIn(AccountModel account) async {
    try {
      dynamic data = dfxService.getAddressAndSignature(account);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/auth/signIn');

      final headers = {
        'Content-type': 'application/json',
      };

      final body = jsonEncode(data);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['accessToken'];
      } else {
        return await signUp(account);
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> createUser(String email, String phone,
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/user');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final body = jsonEncode({
        'mail': email,
        'phone': phone,
      });

      final response = await http.put(url, headers: headers, body: body);

    } catch (_) {
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/user');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<List<AssetByFiatModel>> getAvailableAssets(
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/asset');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<AssetByFiatModel> assets = List.generate(
            data.length, (index) => AssetByFiatModel.fromJson(data[index]));
        return assets;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> saveBuyDetails(String iban, AssetByFiatModel asset,
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/buy');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final body = jsonEncode({
        'type': "Wallet",
        'iban': iban,
        'asset': asset.toJson(),
      });

      final response = await http.post(url, headers: headers, body: body);

    } catch (_) {
    }
  }

  Future<List<IbanModel>> getIbanList(
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/route');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> dataBuy = jsonDecode(response.body)["buy"];
        List<dynamic> dataSell = jsonDecode(response.body)["sell"];
        List<IbanModel> buyIbanList = List.generate(
            dataBuy.length, (index) => IbanModel.fromJson(dataBuy[index]));
        List<IbanModel> sellIbanList = List.generate(
            dataSell.length, (index) => IbanModel.fromJson(dataSell[index]));
        buyIbanList.addAll(sellIbanList);
        return buyIbanList;
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getCountryList(String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/country');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
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

  Future<void> saveKycData(KycModel kyc,
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/kyc/data');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final body = jsonEncode(kyc.toJson());

      final response = await http.post(url, headers: headers, body: body);
    } catch (_) {
      print(_);
    }
  }

  Future<List<FiatModel>> getFiatList(
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/fiat');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> data = jsonDecode(response.body);
        List<FiatModel> fiatList = List.generate(
            data.length, (index) => FiatModel.fromJson(data[index]));
        return fiatList;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<Map> sell(String iban, FiatModel fiat,
      String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/sell');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final body = jsonEncode({
        'iban': iban,
        'fiat': fiat.toJson(),
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        if (response.statusCode == 409) {
          throw Error.safeToString('Iban already exist');
        } else {
          throw Error.safeToString('Other error');
        }
      }
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, dynamic>> getStakingRouteBalance(
    String accessToken,
    String address,
  ) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse(
          'https://api.dfx.swiss/v1/staking/routeBalance?addresses=$address}');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<List<StakingModel>> getStakingRoutes(String accessToken) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse('https://api.dfx.swiss/v1/staking');

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<StakingModel> routes = List.generate(
            data.length, (index) => StakingModel.fromJson(data[index]));
        return routes;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, dynamic>> postStaking(
    String rewardType,
    String paymentType,
    AssetByFiatModel? rewardAsset,
    AssetByFiatModel? paybackAsset,
    IbanModel? rewardSell,
    IbanModel? paybackSell,
    String accessToken,
    { bool isActive = false, int stakingId = 0 }
  ) async {
    try {
      String decryptedAccessToken = await getDecryptedAccessToken(accessToken);

      final Uri url = Uri.parse(
          'https://api.dfx.swiss/v1/staking/' +
          (isActive ? stakingId.toString() : ''));

      final headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $decryptedAccessToken'
      };

      var body = {
        'rewardType': rewardType,
        'paybackType': paymentType,
        'rewardAsset': rewardAsset == null ? {} : rewardAsset.toJson(),
        'paybackAsset': paybackAsset == null ? {} : paybackAsset.toJson(),
        'rewardSell': rewardSell == null ? {} : rewardSell.toJson(),
        'paybackSell': paybackSell == null ? {} : paybackSell.toJson(),
      };

      if (isActive) {
        body['active'] = true;
      }
      final bodyEncode = jsonEncode(body);

      var response;
      if (isActive) {
        response = await http.put(url, headers: headers, body: bodyEncode);
      } else {
        response = await http.post(url, headers: headers, body: bodyEncode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        String errMessage = jsonDecode(response.body.toString())["message"];
        throw Error.safeToString(errMessage);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<String> getDecryptedAccessToken(String accessToken) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var box = await Hive.openBox(HiveBoxes.client);
    var encodedPassword = await box.get(HiveNames.password);
    var password = stringToBase64.decode(encodedPassword);
    return encryptHelper.getDecryptedData(accessToken, password);
  }
}
