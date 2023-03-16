import 'package:js/js.dart';

class LedgerTransactionInput {
  String prevout;
  String script;
  int sequence;
  int index;
  int order;

  LedgerTransactionInput(
      this.order, this.prevout, this.script, this.sequence, this.index);
}

class LedgerTransactionRaw {
  String txId;
  String rawTx;
  int index;
  String redeemScript;

  LedgerTransactionRaw(this.txId, this.rawTx, this.index, this.redeemScript);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["txId"] = this.txId;
    data["rawTx"] = this.rawTx;
    data["index"] = this.index;
    data["redeemScript"] = this.redeemScript;
    return data;
  }
}

@JS('jelly_init')
external void jellyLedgerInit();

@JS('openAppInTab')
external void openInTab();

@JS('isUsbSupported')
external bool isUsbSupported();

@JS('ledger.openLedgerDefichain')
external int openLedgerDefichain(String appName);

@JS('ledger.getAddress')
external String getAddress(
    String path,
    bool
        verify); //we return a json string now, and decode. Wrapped objects sucks in dart

@JS('ledger.signMessage')
external String signMessageLedger(String path, String message);

@JS('ledger.signTransactionRaw')
external String signTransactionLedgerRaw(String transactionsJson,
    List<String> paths, String newTx, String network, String changePath);
