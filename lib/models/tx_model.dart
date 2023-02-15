import 'abstract_tx_model.dart';

class TxModel implements AbstractTransaction {
  String? txid;
  String? type;
  String? hash;
  String? amount;
  String? token;
  int? time;
  List<dynamic>? amounts;

  TxModel(
      {this.txid,
      this.type,
      this.hash,
      this.amount,
      this.token,
      this.time,
      this.amounts});

  TxModel.fromJson(Map<String, dynamic> json) {
    this.txid = json["txid"];
    this.type = json["type"];
    this.hash = json["block"]["hash"];
    this.amount = json["value"] == null
        ? json["amounts"][0].split('@')[0]
        : json["value"];
    this.token = json["amounts"] == null
        ? 'DFI'
        : json["amounts"][0].split('@')[1];
    this.time = json["block"]["time"];
    this.amounts = json["amounts"] == null
        ? []
        : json["amounts"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["txid"] = this.txid;
    data["type"] = this.type;
    data["block"] = this.hash;
    data["amount"] = this.amount;
    data["token"] = this.token;
    data["time"] = this.time;
    data["amounts"] = this.amounts;
    return data;
  }
}
