import 'dart:math';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/requests/bitcoin/blockcypher_requests.dart';
import 'package:defichaindart/defichaindart.dart';

import 'package:defi_wallet/models/utxo_model.dart';

class BTCTransactionService {
  static const DUST = 3000;

  static Future<TxErrorModel> createSendTransaction(
      {required String senderAddress,
      required ECPair keyPair,
      required String destinationAddress,
      required BitcoinNetworkModel network,
      required int amount,
      required BalanceModel balance,
      required int satPerByte}) async {
    //romance portion fit sea price casual forward piano afraid erosion want replace excite figure place butter fortune empower rotate safe surface person distance simple
    //https://api.blockcypher.com/v1/btc/test3/addrs/tb1qhwqqsktldqypttltr59px506p890ce0sgj0fe7?unspentOnly=true

    var utxos = await BlockcypherRequests.getUTXOs(
        network: network, addressString: senderAddress);
    var fee = calculateBTCFee(2, 2, satPerByte);
    int sumUTXO = utxos.length > 0
        ? utxos.map((item) => item.value!).reduce((a, b) => a + b)
        : 0;
    if (sumUTXO < fee + amount) {
      return TxErrorModel(
          isError: true,
          error:
              'Not enough balance. Please wait for the previous transaction');
    }
    var selectedUtxo = _utxoSelector(utxos, fee, amount);
    if (selectedUtxo.length > 2) {
      selectedUtxo = _utxoSelector(
          utxos, calculateBTCFee(2, selectedUtxo.length, satPerByte), amount);
    }

    final _txb = TransactionBuilder(network: network.getNetworkType());
    _txb.setVersion(2);
    var amountUtxo = 0;
    selectedUtxo.forEach((utxo) {
      amountUtxo += utxo.value!;
      _txb.addInput(
          utxo.mintTxId,
          utxo.mintIndex,
          null,
          P2WPKH(
                  data: PaymentData(pubkey: keyPair.publicKey),
                  network: network.getNetworkType())
              .data!
              .output);
    });

    _txb.addOutput(destinationAddress, amount);
    if (amountUtxo > amount + fee + DUST) {
      _txb.addOutput(senderAddress, amountUtxo - (amount + fee));
    }
    selectedUtxo.asMap().forEach((index, utxo) {
      _txb.sign(vin: index, keyPair: keyPair, witnessValue: utxo.value);
    });
    TxErrorModel tx = await BlockcypherRequests.sendTxHex(network, _txb.build().toHex());
    tx.txLoaderList![0].type = TxType.send;
    return tx;
  }

  static int calculateBTCFee(int inputCount, int outputCount, int satPerByte) {
    int txBodySize = 10;
    int txInputSize = 148;
    int txOutputSize = 34;

    return (txBodySize +
            inputCount * txInputSize +
            txOutputSize * outputCount) *
        satPerByte;
  }

  static List<UtxoModel> _utxoSelector(List<UtxoModel> utxos, int fee, int amount) {
    utxos = _shuffle(utxos);
    List<UtxoModel> selectedUtxo = [];
    int sum = 0;
    int i = 0;
    do {
      selectedUtxo.add(utxos[i]);
      sum += utxos[i].value!;
      if (selectedUtxo.length < utxos.length) {
        i++;
      } else {
        break;
      }
    } while (sum <= amount + fee || sum - (amount + fee) < DUST);
    return selectedUtxo;
  }

  static List<UtxoModel> _shuffle(List<UtxoModel> items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {
      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }
}
