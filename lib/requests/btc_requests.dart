import 'dart:convert';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/fiat_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/models/kyc_model.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/services/dfx_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:defi_wallet/helpers/settings_helper.dart';

class BtcRequests {
  String host = 'https://api.blockcypher.com/v1';

  Future<List<UtxoModel>> getUTXOs({required AddressModel address}) async {
    List<UtxoModel> utxos = [];
    try {
      final Uri url = Uri.parse('$host/btc/${SettingsHelper.settings.network == 'mainnet' ? 'main' : 'test3'}/addrs/${address.address}?unspentOnly=true');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var responseDecode = jsonDecode(response.body);
        if (responseDecode['txrefs'] == null) {
          return <UtxoModel>[];
        }
        List<dynamic> data = jsonDecode(response.body)['txrefs'];
        data.map((utxo) {
          var utxoModel = UtxoModel();
          utxoModel.address = address.address;
          utxoModel.mintTxId = utxo['tx_hash'];
          utxoModel.mintIndex = utxo['tx_output_n'];
          utxoModel.value = utxo['value'];
          utxos.add(utxoModel);
        }).toList();
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
    utxos = utxos.toSet().toList();
    return utxos;
  }

  Future<List<dynamic>> getTransactionHistory({required AddressModel address}) async {
    try {
      final Uri url = Uri.parse('$host/btc/${SettingsHelper.settings.network == 'mainnet' ? 'main' : 'test3'}/addrs/${address.address}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        var responseDecode = jsonDecode(response.body);
        if (responseDecode['txrefs'] == null) {
          return [<HistoryModel>[], 'done'];
        }
        dynamic data = jsonDecode(response.body)['txrefs'];
        Map<String, HistoryModel> txs = {};
        data.forEach((tx){
          if(txs[tx['tx_hash']] == null){
            txs[tx['tx_hash']] = HistoryModel(
                value: tx['tx_input_n'] < 0 ?  tx['value'] : -1 * tx['value'],
                txid: tx['tx_hash'],
                blockTime: tx['confirmed']);
          } else {
            txs[tx['tx_hash']]!.value = (txs[tx['tx_hash']]!.value! + (tx['tx_input_n'] < 0 ? tx['value'] : -1 * tx['value'])).toInt();
          }
        });
        
        var txList = txs.values.toList();
        txList.forEach((tx){
          if(tx.value! > 0){
            tx.type = 'vin';
            tx.isSend = false;
          } else {
            tx.type = 'vout';
            tx.isSend = true;
          }
        });
        return [txList, 'done'];
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }


  Future<NetworkFeeModel> getNetworkFee() async {
    try {
      final Uri url = Uri.parse('$host/btc/${SettingsHelper.settings.network == 'mainnet' ? 'main' : 'test3'}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        return NetworkFeeModel(low: (data['low_fee_per_kb']/1000).toInt(), medium: (data['medium_fee_per_kb']/1000).toInt(), high: (data['high_fee_per_kb']/1000).toInt());
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<List<int>> getBalance({required AddressModel address}) async {
    try {
      final Uri url = Uri.parse('$host/btc/${SettingsHelper.settings.network == 'mainnet' ? 'main' : 'test3'}/addrs/${address.address}/balance');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        return [data['final_balance'], data['unconfirmed_balance']];
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<int> getAvailableBalance({required AddressModel address,required int feePerByte}) async {
    List<int> balance = await getBalance(address: address);
    var utxos = await getUTXOs(address:address);
    var fee = TransactionService().calculateBTCFee(utxos.length,1 ,feePerByte);
    return balance[0] - fee;
  }

  Future<TxErrorModel> sendTxHex(String txHex) async {
      String urlAddress = '$host/btc/${SettingsHelper.settings.network == 'mainnet' ? 'main' : 'test3'}/txs/push';

      final Uri _url = Uri.parse(urlAddress);

      final _headers = {
        'Content-type': 'application/json',
      };

      final _body = jsonEncode({
        'tx': txHex,
      });

      final response = await http.post(_url, headers: _headers, body: _body);
      final data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 201) {
        return TxErrorModel(isError: false, txid: data['tx']['hash']);
      } else {
        return TxErrorModel(isError: true, error: data['error']);
      }
  }
}
