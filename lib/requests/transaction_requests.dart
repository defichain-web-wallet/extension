import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

import '../models/settings_model.dart';

class HttpError implements Exception {
  final int errorCode;

  HttpError({required this.errorCode});
}

class TransactionRequests {
  var addressesHelper = AddressesHelper();

  Future<List<UtxoModel>> getUTXOs({required List<AddressModel> addresses, String fallbackUrl = ''}) async {
    List<UtxoModel> utxos = [];

    for (var i = 0; i < addresses.length; i++) {
      try {
        String hostUrl = SettingsHelper.getHostApiUrl();
        String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/${SettingsHelper.settings.network}/address/${addresses[i].address}/transactions/unspent' : fallbackUrl;

        final Uri _url = Uri.parse(urlAddress);
        final _headers = {
          'Content-type': 'application/json',
        };

        final _response = await http.get(_url, headers: _headers);
        final _data = jsonDecode(_response.body)['data'].cast<Map<String, dynamic>>();
        _data.forEach((utxo) {
          var utxoModel = UtxoModel.fromJson(utxo);
          utxoModel.address = addresses[i].address;
          utxos.add(utxoModel);
        });
      } catch (err) {
        if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
          String fallbackUrlAddress = SettingsHelper.settings.network == 'mainnet'
              ? 'http://ocean.mydefichain.com:3000/v0/mainnet/address/${addresses[i].address}/transactions/unspent'
              : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/address/${addresses[i].address}/transactions/unspent';
          return getUTXOs(addresses: addresses, fallbackUrl: fallbackUrlAddress);
        } else {
          throw err;
        }
      }
    }
    utxos = utxos.toSet().toList();
    return utxos;
  }

  Future<String> loadRawTransaction({required String txId}) async {
    try {
      String hostUrl = Hosts.ocean;
      String urlAddress = '$hostUrl/${SettingsHelper.settings.network}/rawtx/$txId';

      final Uri _url = Uri.parse(urlAddress);
      final _headers = {
        'Content-type': 'application/json',
      };

      final _response = await http.get(_url, headers: _headers);

      if (_response.statusCode != 200) {
        throw HttpError(errorCode: _response.statusCode);
      }

      if (_response.body.contains("error")) {
        var errorData = jsonDecode(_response.body)['error'];
        throw HttpError(errorCode: errorData.code);
      }

      var data = jsonDecode(_response.body)['data'];

      return data;
    } on HttpError catch (_) {
      throw _;
    } catch (err) {
      throw err;
    }
  }

  Future<Map<String, dynamic>> loadTransaction({required String txId, String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/${SettingsHelper.settings.network}/transactions/$txId' : fallbackUrl;

      final Uri _url = Uri.parse(urlAddress);
      final _headers = {
        'Content-type': 'application/json',
      };

      final _response = await http.get(_url, headers: _headers);

      if (_response.statusCode != 200) {
        throw HttpError(errorCode: _response.statusCode);
      }

      var data = jsonDecode(_response.body)['data'];

      return data;
    } on HttpError catch (_) {
      throw _;
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = SettingsHelper.settings.network == 'mainnet'
            ? 'http://ocean.mydefichain.com:3000/v0/mainnet/transactions/$txId'
            : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/transactions/$txId';
        return loadTransaction(txId: txId, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<List<dynamic>> loadTransactionVins({required String txId, String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/${SettingsHelper.settings.network}/transactions/$txId/vins' : fallbackUrl;

      final Uri _url = Uri.parse(urlAddress);
      final _headers = {
        'Content-type': 'application/json',
      };

      final _response = await http.get(_url, headers: _headers);

      if (_response.statusCode != 200) {
        throw HttpError(errorCode: _response.statusCode);
      }
      var data = jsonDecode(_response.body)['data'];

      return data;
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = SettingsHelper.settings.network == 'mainnet'
            ? 'http://ocean.mydefichain.com:3000/v0/mainnet/transactions/$txId/vins'
            : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/transactions/$txId/vins';
        return loadTransactionVins(txId: txId, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<List<dynamic>> loadTransactionVouts({required String txId, String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/${SettingsHelper.settings.network}/transactions/$txId/vouts' : fallbackUrl;

      final Uri _url = Uri.parse(urlAddress);
      final _headers = {
        'Content-type': 'application/json',
      };

      final _response = await http.get(_url, headers: _headers);

      if (_response.statusCode != 200) {
        throw HttpError(errorCode: _response.statusCode);
      }
      var data = jsonDecode(_response.body)['data'];

      return data;
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = SettingsHelper.settings.network == 'mainnet'
            ? 'http://ocean.mydefichain.com:3000/v0/mainnet/transactions/$txId/vouts'
            : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/transactions/$txId/vouts';
        return loadTransactionVouts(txId: txId, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
  }

  Future<TxErrorModel> sendTxHex(String txHex, {String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl();
      String urlAddress = fallbackUrl.isEmpty ? '$hostUrl/${SettingsHelper.settings.network}/rawtx/send' : fallbackUrl;

      final Uri _url = Uri.parse(urlAddress);

      final _headers = {
        'Content-type': 'application/json',
      };

      final _body = jsonEncode({
        'hex': txHex,
      });

      final response = await http.post(_url, headers: _headers, body: _body);
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return TxErrorModel(isError: false, txLoaderList: [TxLoaderModel(txId: data['data'], txHex: txHex)]);
      } else {
        return TxErrorModel(isError: true, error: data['error']['message']);
      }
    } catch (err) {
      if (fallbackUrl.isEmpty && SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = SettingsHelper.settings.network == 'mainnet'
            ? 'http://ocean.mydefichain.com:3000/v0/mainnet/address/mainnet/rawtx/send'
            : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/rawtx/send';
        return sendTxHex(txHex, fallbackUrl: fallbackUrlAddress);
      } else {
        return TxErrorModel(isError: true, error: jsonEncode(err));
      }
    }
  }
}
