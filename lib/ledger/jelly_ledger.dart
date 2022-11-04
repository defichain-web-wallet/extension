import 'dart:typed_data';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

class LedgerTransactionInput {
  String prevout;
  String script;
  int sequence;
  int index;

  int order;

  LedgerTransactionInput(this.order, this.prevout, this.script, this.sequence, this.index);
}

class LedgerTransactionRaw {
  String txId;
  String rawTx;

  int index;
  String redeemScript;

  LedgerTransactionRaw(this.txId, this.rawTx, this.index, this.redeemScript);
}

class LedgerTransaction {
  int version;
  String txId;
  List<LedgerTransactionInput> inputs;
  List<LedgerTransactionOutput> outputs;

  int lockTime;

  int index;
  int sequenceNumber;
  String redeemScript;
  String witnesses;

  LedgerTransaction(this.version, this.txId, this.inputs, this.outputs, this.index, this.sequenceNumber, this.lockTime, this.redeemScript, this.witnesses);
}

class LedgerTransactionOutput {
  int amount;
  String script;

  LedgerTransactionOutput(this.amount, this.script);
}

@JS('jelly_init')
external void jellyLedgerInit();

@JS('ledger.getAddress')
external dynamic getAddress(String path, bool verify);

@JS('ledger.signMessage')
external String signMessageLedger(String path, String message);

@JS('ledger.rawTxToPsbt')
external String rawTxToPsbt(String hex, String network);

@JS('ledger.signTransaction')
external String signTransactionLedger(List<LedgerTransaction> transaction, List<String> paths, String newTx, String network);

@JS('ledger.signTransactionRaw')
external String signTransactionLedgerRaw(List<LedgerTransactionRaw> transaction, List<String> paths, String newTx, String network, String changePath);
