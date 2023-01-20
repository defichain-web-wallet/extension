import 'dart:js_util';
import 'dart:typed_data';

import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/ledger/jelly_ledger.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:defi_wallet/services/signing_service.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:hex/hex.dart';
import 'package:retry/retry.dart';

class LedgerSigningService implements SigningWalletService {
  var transactionRequests = TransactionRequests();

  @override
  Future<Uint8List> getPublicKey(AccountModel accountModel, String address, String network) async {
    var addressModel = accountModel.addressList!.firstWhere((element) => element.address == address);
    var compressedKey = _compressPubkey(pubkey: addressModel.pubKey!);
    return compressedKey;
  }

  @override
  Future<String> signTransaction(TransactionBuilder txBuilder, AccountModel accountModel, List<UtxoModel> utxoModel, String network, String changePath) async {
    var prevOuts = List<LedgerTransactionRaw>.empty(growable: true);
    var paths = List<String>.empty(growable: true);

    for (var element in utxoModel) {
      var addressModel = accountModel.addressList!.firstWhere((element) => element.address == element.address);
      var path = addressModel.getPath();
      paths.add(path);
      final pubKey = await getPublicKey(accountModel, element.address!, network);

      final p2wpkh = P2WPKH(data: PaymentData(pubkey: pubKey), network: NetworkHelper().getNetwork(network)).data!;
      final redeemScript = p2wpkh.output;
      final redemHex = HEX.encode(redeemScript!);

      final r = RetryOptions(maxAttempts: 10, maxDelay: Duration(seconds: 10));

      var rawTx = await r.retry(() async {
        return await transactionRequests.loadRawTransaction(txId: element.mintTxId!);
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

      prevOuts.add(LedgerTransactionRaw(element.mintTxId!, rawTx, element.mintIndex!, redemHex));
    }

    final tx = txBuilder.buildIncomplete();
    final txhex = tx.toHex();

    var txHex = await promiseToFuture(signTransactionLedgerRaw(prevOuts, paths, txhex, network, changePath));
    return txHex;
  }

  @override
  Future<String> signMessage(AccountModel accountModel, String address, String message, String network) async {
    var signature = await promiseToFuture(signMessageLedger(accountModel.addressList![0].getPath(), message));
    return signature;
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
}
