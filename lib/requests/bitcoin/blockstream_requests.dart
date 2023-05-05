import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';

class BlockstreanRequests {
  static Future<String> getTransactionRaw({
    required BitcoinNetworkModel network,
    required String txId,
  }) async {
    try {
      final Uri url = Uri.parse(
          '${Hosts.blockstreamApi}/${network.networkType.isTestnet ? 'testnet' : ''}/api/tx/$txId/hex');

      final response = await https.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Error.safeToString(response.statusCode);
      }
    } catch (err) {
      throw err;
    }
  }
}
