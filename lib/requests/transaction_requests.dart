import 'dart:convert';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

class TransactionRequests {
  var networkHelper = NetworkHelper();
  var addressesHelper = AddressesHelper();
  Future<List<UtxoModel>> getUTXOs({
    required List<AddressModel> addresses,
  }) async {
    List<UtxoModel> utxos = [];

    for(var i = 0; i < addresses.length; i++){
      try {
        final Uri _url = Uri.parse(
            'https://ocean.defichain.com/v0/${networkHelper.getNetworkString()}/address/${addresses[i].address}/transactions/unspent');
        final _headers = {
          'Content-type': 'application/json',
        };

        final _response = await http.get(_url, headers: _headers);
        final _data = jsonDecode(_response.body)['data'].cast<Map<String, dynamic>>();

        _data.map<UtxoModel>((utxo){
          var utxoModel = UtxoModel.fromJson(utxo);
          utxoModel.address = addresses[i].address;
          utxoModel.keyPair = addresses[i].keyPair;
          utxos.add(utxoModel);
        }).toList();

      } catch (_) {}
    }
    utxos = utxos.toSet().toList();
    return  utxos;
  }

  Future<TxErrorModel> sendTxHex(String txHex) async {
    try {
      final Uri _url = Uri.parse(
          'https://ocean.defichain.com/v0/${networkHelper.getNetworkString()}/rawtx/send');

      final _headers = {
        'Content-type': 'application/json',
      };

      final _body = jsonEncode({
        'hex': txHex,
      });

      final response = await http.post(_url, headers: _headers, body: _body);
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return TxErrorModel(isError: false, txid: data['data']);
      } else {
        return TxErrorModel(isError: true, error: data['error']['message']);
      }
    } catch (__) {
      return  TxErrorModel(isError: true, error: jsonEncode(__));
    }
  }
}
