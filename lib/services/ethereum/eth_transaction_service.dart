import 'dart:math';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class ETHTransactionService {
  static Future<TxErrorModel> createSendTransaction(
      {required String senderAddress,
      required Credentials credentials,
      required String destinationAddress,
      required int amount,
      required String rpcUrl,
      required int maxGas, required int gasPrice}) async {
    final client = Web3Client(rpcUrl, Client());
    try {
      var tx = await client.sendTransaction(
        credentials,
        fetchChainIdFromNetworkId: true,
        chainId: null,
        Transaction(
          from: EthereumAddress.fromHex(senderAddress),
          to: EthereumAddress.fromHex(destinationAddress),
          gasPrice: EtherAmount.inWei(BigInt.parse(gasPrice.toString())),
          maxGas: maxGas,
          value: EtherAmount.fromInt(EtherUnit.wei, amount),
        ),
      );
      return TxErrorModel(
          isError: false, txLoaderList: [TxLoaderModel(txId: tx)]);
    } catch (e) {
      print(e);
      return TxErrorModel(isError: true, error: e.toString());
    }
  }
}
