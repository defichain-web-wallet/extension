import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as http;

class DFITransactionRequests {
  static Future<List<UtxoModel>> getUTXOs({
    required String address,
    required AbstractNetworkModel network,
    Uri? fallbackUri,
  }) async {
    List<UtxoModel> utxos = [];

    try {
      final Uri _url = fallbackUri == null ? Uri.https(
        network.networkType.isTestnet ? Hosts.testnetHost : Hosts.mainnetHost,
        '/v0/${network.networkType.networkStringLowerCase}/address/$address/transactions/unspent',
      ) : fallbackUri!;

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
      if (fallbackUri == null) {
        final Uri _fallbackUri = Uri.https(
          network.networkType.isTestnet ? Hosts.fallbackTestnetHost : Hosts.fallbackMainnetHost,
          '/v0/${network.networkType.networkStringLowerCase}/address/$address/transactions/unspent',
        );
        return getUTXOs(
          address: address,
          network: network,
          fallbackUri: _fallbackUri,
        );
      } else {
        throw err;
      }
    }
    utxos = utxos.toSet().toList();
    return utxos;
  }

  static Future<TxErrorModel> sendTxHex({
    required String txHex,
    required AbstractNetworkModel network,
    Uri? fallbackUri,
  }) async {
    try {
      final Uri _url = fallbackUri == null ? Uri.https(
        network.networkType.isTestnet ? Hosts.testnetHost : Hosts.mainnetHost,
        '/v0/${network.networkType.networkStringLowerCase}/rawtx/send',
      ) : fallbackUri!;

      final _headers = {
        'Content-type': 'application/json',
      };

      final _body = jsonEncode({
        'hex': txHex,
      });

      final response = await http.post(_url, headers: _headers, body: _body);
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return TxErrorModel(
          isError: false,
          txLoaderList: [
            TxLoaderModel(
              txId: data['data'],
              txHex: txHex,
            ),
          ],
        );
      } else {
        return TxErrorModel(
          isError: true,
          error: data['error']['message'],
        );
      }
    } catch (err) {
      if (fallbackUri == null) {
        final Uri _fallbackUri = Uri.https(
          network.networkType.isTestnet ? Hosts.fallbackTestnetHost : Hosts.fallbackMainnetHost,
          '/v0/${network.networkType.networkStringLowerCase}/rawtx/send',
        );
        return sendTxHex(
          txHex: txHex,
          network: network,
          fallbackUri: _fallbackUri,
        );
      } else {
        return TxErrorModel(
          isError: true,
          error: jsonEncode(err),
        );
      }
    }
  }
}
