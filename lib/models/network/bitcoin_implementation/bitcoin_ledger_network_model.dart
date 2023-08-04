import 'dart:convert';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/ledger_account_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/requests/bitcoin/blockcypher_requests.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:defi_wallet/services/bitcoin/btc_transaction_service.dart';
import 'package:defi_wallet/services/signing_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hex/hex.dart';
import 'package:retry/retry.dart';

class BitcoinLedgerSigningService extends SigningService {
  BitcoinNetworkModel network;
  String address;
  String path;
  Uint8List pubKey;

  BitcoinLedgerSigningService(
      {required this.network,
      required this.address,
      required this.pubKey,
      required this.path});

  @override
  Future<Uint8List> getPublicKey() async {
    return _compressPubkey(pubkey: pubKey);
  }

  Uint8List _compressPubkey({required Uint8List pubkey}) {
    if (pubkey.length == 65) {
      var parity = pubkey[64] & 1;
      var newKey = pubkey.getRange(0, 33).toList();
      newKey[0] = 2 | parity;
      return Uint8List.fromList(newKey);
    }
    return pubkey;
  }

  @override
  Future<String> signTransaction(TransactionBuilder txBuilder,
      List<UtxoModel> utxoModel, String changePath) async {
    var prevOuts = List<LedgerTransactionRaw>.empty(growable: true);
    var prevOutsJson = List<dynamic>.empty(growable: true);
    var paths = List<String>.empty(growable: true);

    for (var element in utxoModel) {
      paths.add(this.path);
      final pubKey = this.pubKey;

      final p2wpkh =
          P2WPKH(data: PaymentData(pubkey: pubKey), network: txBuilder.network)
              .data!;
      final redeemScript = p2wpkh.output;
      final redemHex = HEX.encode(redeemScript!);

      final r = RetryOptions(maxAttempts: 10, maxDelay: Duration(seconds: 10));

      var rawTx = await r.retry(() async {
        return await BlockcypherRequests.getRawTx(
            network: this.network, txHash: element.mintTxId!);
      }, retryIf: (e) async {
        if (e is HttpError) {
          if (e.errorCode == 404) {
            return true;
          }
        }
        return false;
      }, onRetry: (e) {
        print("error create loading tx, retry again");
      });

      var prevOut = LedgerTransactionRaw(
          element.mintTxId!, rawTx, element.mintIndex!, redemHex);
      prevOuts.add(prevOut);
      prevOutsJson.add(prevOut.toJson());
    }

    final tx = txBuilder.buildIncomplete();
    final txhex = tx.toHex();

    try {
      var jsonString = json.encode(prevOutsJson);
      jellyLedgerInit();

      final appName = network.networkType.isTestnet ? "test" : "btc";

      var txHex = await promiseToFuture(signTransactionLedgerRaw(
          appName,
          jsonString,
          paths,
          txhex,
          txBuilder.network!.messagePrefix,
          changePath));
      return txHex;
    } catch (err) {
      print(err);
      throw new Exception(err);
    }
  }
}

class BitcoinLedgerNetworkModel extends BitcoinNetworkModel {
  BitcoinLedgerNetworkModel(NetworkTypeModel networkType) : super(networkType);

  factory BitcoinLedgerNetworkModel.fromJson(Map<String, dynamic> json) {
    return BitcoinLedgerNetworkModel(
      NetworkTypeModel.fromJson(json['networkType']),
    );
  }

  @override
  Future<TxErrorModel> send(
      {required AbstractAccountModel account,
      required String address,
      required String password,
      required TokenModel token,
      required double amount,
      required ApplicationModel applicationModel,
      int satPerByte = 0}) async {
    if (satPerByte == 0) {
      var networkFee = await BlockcypherRequests.getNetworkFee(this);
      satPerByte = networkFee.medium!;
    }

    List<BalanceModel> balances = account.getPinnedBalances(this);
    final pubKeyUint =
        Uint8List.fromList(HEX.decoder.convert(account.publicKeyMainnet!));
    final addressPath = (account as LedgerAccountModel).path;

    return BTCTransactionService.createSendTransaction(
        senderAddress: account.getAddress(this.networkType.networkName)!,
        signingService: new BitcoinLedgerSigningService(
            network: this,
            address: address,
            pubKey: pubKeyUint,
            path: addressPath),
        balance: balances[0],
        destinationAddress: address,
        network: this,
        amount: toSatoshi(amount),
        satPerByte: satPerByte);
  }
}
