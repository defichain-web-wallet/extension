import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

import '../../models/settings_model.dart';

class DFITransactionRequests {
  var addressesHelper = AddressesHelper();

  static Future<List<UtxoModel>> getUTXOs(
      {required String address, required String networkString, String fallbackUrl = ''}) async {
    List<UtxoModel> utxos = [];

    try {
      String hostUrl = SettingsHelper.getHostApiUrl(); //TODO: need to change this part
      String urlAddress = fallbackUrl.isEmpty
          ? '$hostUrl/$networkString/address/$address/transactions/unspent'
          : fallbackUrl;

      final Uri _url = Uri.parse(urlAddress);
      final _headers = {
        'Content-type': 'application/json',
      };

      final _response = await http.get(_url, headers: _headers);
      final _data =
      jsonDecode(_response.body)['data'].cast<Map<String, dynamic>>();
      _data.forEach((utxo) {
        var utxoModel = UtxoModel.fromJson(utxo);
        utxoModel.address = address;
        utxos.add(utxoModel);
      });
    } catch (err) {
      if (fallbackUrl.isEmpty &&
          SettingsHelper.settings.apiName == ApiName.auto) {
        String fallbackUrlAddress = networkString ==
            'mainnet'
            ? 'http://ocean.mydefichain.com:3000/v0/mainnet/address/$address/transactions/unspent'
            : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/address/$address/transactions/unspent';
        return getUTXOs(
            address: address, networkString: networkString, fallbackUrl: fallbackUrlAddress);
      } else {
        throw err;
      }
    }
    utxos = utxos.toSet().toList();
    return utxos;
  }

  static Future<TxErrorModel> sendTxHex({required String txHex, required String networkString,
      String fallbackUrl = ''}) async {
    try {
      String hostUrl = SettingsHelper.getHostApiUrl(); //TODO: need to change this part
      String urlAddress = fallbackUrl.isEmpty
          ? '$hostUrl/$networkString/rawtx/send'
          : fallbackUrl;

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
        String fallbackUrlAddress = networkString == 'mainnet'
            ? 'http://ocean.mydefichain.com:3000/v0/mainnet/address/mainnet/rawtx/send'
            : 'https://testnet-ocean.mydefichain.com:8443/v0/testnet/rawtx/send';
        return sendTxHex(txHex: txHex, networkString: networkString, fallbackUrl: fallbackUrlAddress);
      } else {
        return TxErrorModel(isError: true, error: jsonEncode(err));
      }
    }
  }
}
