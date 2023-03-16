// ignore_for_file: unused_import

import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'dart:typed_data';

import 'package:defi_wallet/services/signing_service.dart';
import 'package:defichaindart/defichaindart.dart';

class LocalSigningService implements SigningWalletService {
  @override
  Future<Uint8List> getPublicKey(
      AccountModel accountModel, String address, String network,
      {ECPair? key}) async {
    if (key == null) {
      throw new Exception("key cannot be null here!");
    }
    var pubKey = key;
    return pubKey.publicKey!;
  }

  @override
  Future<String> signTransaction(
      TransactionBuilder txBuilder,
      AccountModel accountModel,
      List<UtxoModel> utxoModel,
      String network,
      String changePath,
      {ECPair? key}) async {
    if (key == null) {
      throw new Exception("key cannot be null here!");
    }
    int index = 0;
    for (var utxo in utxoModel) {
      var privateKey = key;
      txBuilder.sign(vin: index, keyPair: privateKey, witnessValue: utxo.value);
      index++;
    }

    var tx = txBuilder.build();
    return tx.toHex();
  }

  @override
  Future<String> signMessage(
      AccountModel accountModel, String address, String message, String network,
      {ECPair? key}) async {
    if (key == null) {
      throw new Exception("key cannot be null here!");
    }
    var privateKey = key;
    return privateKey.signMessage(message, NetworkHelper().getNetwork(network));
  }
}
