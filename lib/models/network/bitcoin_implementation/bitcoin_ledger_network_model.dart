import 'dart:typed_data';

import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/application_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/token/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/requests/bitcoin/blockcypher_requests.dart';
import 'package:defi_wallet/services/bitcoin/btc_transaction_service.dart';
import 'package:defi_wallet/services/signing_service.dart';
import 'package:defichaindart/defichaindart.dart';

class BitcoinLedgerSigningService extends SigningService {
  String address;
  Uint8List pubKey;
  BitcoinLedgerSigningService({required this.address, required this.pubKey});

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
  Future<String> signTransaction(
      TransactionBuilder txBuilder, List<UtxoModel> utxoModel) async {
    for (var element in utxoModel) {}
    return "";
  }
}

class BitcoinLedgerNetworkModel extends BitcoinNetworkModel {
  BitcoinLedgerNetworkModel(NetworkTypeModel networkType) : super(networkType);

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

    return BTCTransactionService.createSendTransaction(
        senderAddress: account.getAddress(this.networkType.networkName)!,
        signingService: new BitcoinLedgerSigningService(
            address: "", pubKey: Uint8List.fromList([0])),
        balance: balances[0],
        destinationAddress: address,
        network: this,
        amount: toSatoshi(amount),
        satPerByte: satPerByte);
  }
}
