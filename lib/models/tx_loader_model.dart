enum TxStatus { waiting, error, success}
enum TxType { swap, send, removeLiq, addLiq, convertUtxo}

class TxLoaderModel {
  TxStatus? status;
  String? txId;
  String? txHex;
  TxType? type;


  TxLoaderModel({
    this.status = TxStatus.waiting,
    this.txId,
    this.txHex,
    this.type,
  });

  TxLoaderModel.fromJson(Map<String, dynamic> json) {
    this.status = json["status"];
    this.txId = json["txId"];
    this.txHex = json["txHex"];
    this.type = json["type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["status"] = this.status;
    data["txId"] = this.txId;
    data["txHex"] = this.txHex;
    data["type"] = this.type;
    return data;
  }
}
