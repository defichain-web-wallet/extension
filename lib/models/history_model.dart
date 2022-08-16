class HistoryModel {
  int? value;
  String? txid;
  String? id;
  String? blockTime;
  String? type;
  List<String>? amounts;

  HistoryModel({this.value, this.txid, this.id, this.blockTime, this.type, this.amounts});

  HistoryModel.fromJson(Map<String, dynamic> json) {
    this.value = json["value"];
    this.blockTime = json["blockTime"];
    this.type = json["type"];
    this.txid = json["txid"];
    this.id = json["id"];
    this.amounts = json["amounts"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["value"] = this.value;
    data["txid"] = this.txid;
    data["id"] = this.id;
    data["blockTime"] = this.blockTime;
    data["type"] = this.type;
    data["amounts"] = this.amounts;
    return data;
  }
}
