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
      required DeployedContract? contract,
      required int amount,
      required String rpcUrl,
      required int maxGas,
      required int gasPrice}) async {
    final client = Web3Client(rpcUrl, Client());
    if (contract != null) {
      return sendTokenTransaction(
          senderAddress: senderAddress,
          credentials: credentials,
          destinationAddress: destinationAddress,
          contract: contract,
          amount: amount,
          rpcUrl: rpcUrl,
          maxGas: maxGas,
          gasPrice: gasPrice);
    } else {
      return sendUTXOTransaction(
          senderAddress: senderAddress,
          credentials: credentials,
          destinationAddress: destinationAddress,
          amount: amount,
          rpcUrl: rpcUrl,
          maxGas: maxGas,
          gasPrice: gasPrice);
    }
  }

  static Future<TxErrorModel> sendUTXOTransaction(
      {required String senderAddress,
      required Credentials credentials,
      required String destinationAddress,
      required int amount,
      required String rpcUrl,
      required int maxGas,
      required int gasPrice}) async {
    final client = Web3Client(rpcUrl, Client());
    try {
      var tx = await client.sendTransaction(
        credentials,
        fetchChainIdFromNetworkId: true,
        chainId: null,
        Transaction(
          from: EthereumAddress.fromHex(senderAddress),
          to: EthereumAddress.fromHex(destinationAddress),
          gasPrice: EtherAmount.fromInt(EtherUnit.gwei, gasPrice),
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

  static Future<TxErrorModel> sendTokenTransaction(
      {required String senderAddress,
      required Credentials credentials,
      required String destinationAddress,
      required int amount,
      required DeployedContract contract,
      required String rpcUrl,
      required int maxGas,
      required int gasPrice}) async {
    final client = Web3Client(rpcUrl, Client());

    final toAddress = EthereumAddress.fromHex(destinationAddress);
    final amountBigint = BigInt.from(amount);

    final function = contract.function('transfer');
    final data = function.encodeCall(
      [toAddress, amountBigint],
    );

    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [toAddress, amountBigint],
      from: EthereumAddress.fromHex(senderAddress),
      gasPrice: EtherAmount.fromInt(EtherUnit.gwei, gasPrice),
      maxGas: maxGas,
    );
    try {
      var tx = await client.sendTransaction(
          credentials,
          fetchChainIdFromNetworkId: true,
          chainId: null,
          transaction);
      return TxErrorModel(
          isError: false, txLoaderList: [TxLoaderModel(txId: tx)]);
    } catch (e) {
      print(e);
      return TxErrorModel(isError: true, error: e.toString());
    }
  }
}
