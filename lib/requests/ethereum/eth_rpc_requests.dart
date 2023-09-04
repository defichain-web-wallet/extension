import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/balance/bitcoin/blockcypher_balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'dart:convert';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/ethereum_implementation/ethereum_rate_model.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:http/http.dart' as https;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ETHRPCRequests {
  static Future<int> getBalance({
    required String host,
    required String addressString,
  }) async {
    try {
    final client = Web3Client('https://rpc.sepolia.org/', Client());
    return 0;
    // return client.getBalance(EthereumAddress.fromHex(addressString));
    } catch (err) {
      throw err;
    }
  }

  static Future<List<dynamic>> getTransactionHistory({
    required BitcoinNetworkModel network,
    required String addressString,
  }) async {
    try {
      final Uri url = Uri.parse(
          '${Hosts.blockcypherApi}/btc/${network.networkType.isTestnet ? 'test3' : 'main'}/addrs/$addressString');

      final response = await https.get(url);

      if (response.statusCode == 200) {
        var responseDecode = jsonDecode(response.body);
        if (responseDecode['txrefs'] == null) {
          return [<HistoryModel>[], 'done'];
        }
        dynamic data = jsonDecode(response.body)['txrefs'];
        Map<String, HistoryModel> txs = {};
        data.forEach((tx) {
          if (txs[tx['tx_hash']] == null) {
            txs[tx['tx_hash']] = HistoryModel(
                value: tx['tx_input_n'] < 0 ? tx['value'] : -1 * tx['value'],
                txid: tx['tx_hash'],
                blockTime: tx['confirmed']);
          } else {
            txs[tx['tx_hash']]!.value = (txs[tx['tx_hash']]!.value! +
                    (tx['tx_input_n'] < 0 ? tx['value'] : -1 * tx['value']))
                .toInt();
          }
        });

        var txList = txs.values.toList();
        txList.forEach((tx) {
          if (tx.value! > 0) {
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

  static Future<NetworkFeeModel> getNetworkFee(
    BitcoinNetworkModel network,
  ) async {
    try {
      final Uri url = Uri.parse(
          '${Hosts.blockcypherApi}/btc/${network.networkType.isTestnet ? 'test3' : 'main'}');

      final response = await https.get(url);

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        return NetworkFeeModel(
            low: (data['low_fee_per_kb'] / 1000).toInt(),
            medium: (data['medium_fee_per_kb'] / 1000).toInt(),
            high: (data['high_fee_per_kb'] / 1000).toInt());
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<TxErrorModel> sendTxHex(
    BitcoinNetworkModel network,
    String txHex,
  ) async {
    final Uri url = Uri.parse(
        '${Hosts.blockcypherApi}/btc/${network.networkType.isTestnet ? 'test3' : 'main'}/txs/push');

    final headers = {
      'Content-type': 'application/json',
    };

    final body = jsonEncode({
      'tx': txHex,
    });

    final response = await https.post(url, headers: headers, body: body);
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return TxErrorModel(isError: false, txLoaderList: [
         TxLoaderModel(txId: data['tx']['hash'], txHex: txHex)
      ]);
    } else {
      return TxErrorModel(isError: true, error: data['error']);
    }
  }

  Future<EthereumRateModel> loadRates({String symbol = 'ethereum'}) async {
    final query = {
      "ids": "ethereum,"
          "dash,"
          "tether,"
          "usd-coin,"
          "uniswap,"
          "the-open-network,"
          "okb,"
          "chainlink,"
          "matic-network,"
          "bridged-dai-stablecoin-linea,"
          "bridged-wrapped-bitcoin-stargate,"
          "staked-ether,"
          "niccagewaluigielmo42069inu,"
          "aave",
      "vs_currencies": "usd,btc,eur",
    };

    final Uri url = Uri.https(
      'api.coingecko.com',
      '/api/v3/simple/price/',
      query,
    );

    try {
      final response = await https.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EthereumRateModel(rates: data);
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (error) {
      throw error;
    }
  }
}
