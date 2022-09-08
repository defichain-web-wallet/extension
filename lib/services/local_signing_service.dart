import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'dart:typed_data';

import 'package:defi_wallet/services/signing_service.dart';
import 'package:defichaindart/defichaindart.dart';

class LocalSigningService implements SigningWalletService {
  HDWalletService _hdWalletService = HDWalletService();

  @override
  Future<Uint8List> getPublicKey(AccountModel accountModel, String address, String network) async {
    var pubKey = await _hdWalletService.getPrivateKey(accountModel, address, network);
    return pubKey!.publicKey!;
  }

  @override
  Future<String> signTransaction(TransactionBuilder txBuilder, AccountModel accountModel, List<UtxoModel> utxoModel, String network) async {
    for (var utxo in utxoModel) {
      var privateKey = await _hdWalletService.getPrivateKey(accountModel, utxo.address!, network);
      txBuilder.sign(vin: utxo.mintIndex!, keyPair: privateKey, witnessValue: utxo.value);
    }

    var tx = txBuilder.build();
    return tx.toHex();
  }

  @override
  Future<String> signMessage(AccountModel accountModel, String address, String message, String network) async {
    var privateKey = await _hdWalletService.getPrivateKey(accountModel, address, network);
    return privateKey.signMessage(message, NetworkHelper().getNetwork(network));
  }
}
