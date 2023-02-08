enum TxStatus { waiting, error, success }
enum TxType { swap, send, removeLiq, addLiq, convertUtxo }

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

  TxLoaderModel.fromJson(Map<dynamic, dynamic> json) {
    this.status = TxStatus.values
        .firstWhere((e) => e.toString() == json["status"]);
    this.txId = json["txId"];
    this.txHex = json["txHex"];
    this.type = TxType.addLiq;
    this.type = TxType.values
        .firstWhere((e) => e.toString() == json["type"]);
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data["status"] = this.status.toString();
    data["txId"] = this.txId;
    data["txHex"] = this.txHex;
    data["type"] = this.type.toString();
    return data;
  }
}
